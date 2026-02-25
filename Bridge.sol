// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title Bridge
 * @dev Professional-grade bridge logic for cross-chain token transfers.
 */
contract Bridge is Ownable, ReentrancyGuard {
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    IERC20 public token;
    address public validator;

    mapping(bytes32 => bool) public processedHashes;

    event TokensLocked(address indexed user, uint256 amount, uint256 nonce);
    event TokensReleased(address indexed user, uint256 amount, uint256 nonce);

    constructor(address _token, address _validator) Ownable(msg.sender) {
        token = IERC20(_token);
        validator = _validator;
    }

    /**
     * @dev Locks tokens on the source chain to be bridged.
     */
    function lockTokens(uint256 amount, uint256 nonce) external nonReentrant {
        require(amount > 0, "Amount must be > 0");
        
        bytes32 transferHash = keccak256(abi.encodePacked(msg.sender, amount, nonce));
        require(!processedHashes[transferHash], "Transfer already processed");

        token.transferFrom(msg.sender, address(this), amount);
        emit TokensLocked(msg.sender, amount, nonce);
    }

    /**
     * @dev Releases tokens on the destination chain after validating signature.
     */
    function releaseTokens(
        address user,
        uint256 amount,
        uint256 nonce,
        bytes memory signature
    ) external nonReentrant {
        bytes32 messageHash = keccak256(abi.encodePacked(user, amount, nonce));
        bytes32 ethSignedMessageHash = messageHash.toEthSignedMessageHash();

        require(!processedHashes[messageHash], "Transfer already processed");
        require(recoverSigner(ethSignedMessageHash, signature) == validator, "Invalid signature");

        processedHashes[messageHash] = true;
        token.transfer(user, amount);

        emit TokensReleased(user, amount, nonce);
    }

    function recoverSigner(bytes32 _hash, bytes memory _signature) public pure returns (address) {
        return _hash.recover(_signature);
    }

    function updateValidator(address _newValidator) external onlyOwner {
        require(_newValidator != address(0), "Invalid address");
        validator = _newValidator;
    }
}
