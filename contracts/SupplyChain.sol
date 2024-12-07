// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./RawMaterials.sol";
import "./Madicine.sol";
import "./MadicineW_D.sol";
import "./MadicineD_P.sol";

/// @title Blockchain: Pharmaceutical SupplyChain
/// @dev Smart contract for managing the supply chain of pharmaceutical products
contract SupplyChain {
    /// @notice Owner of the contract
    address public owner;

    /// @dev Initiate SupplyChain Contract
    constructor() {
        owner = msg.sender;
    }

    /********************************************** Owner Section *********************************************/
    /// @dev Restricts access to the contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    /// @notice Roles in the supply chain
    enum Roles {
        NoRole,
        Supplier,
        Transporter,
        Manufacturer,
        Wholesaler,
        Distributor,
        Pharma,
        Revoke
    }

    /// @dev Events for user management
    event UserRegistered(address indexed ethAddress, bytes32 name);
    event UserRoleRevoked(address indexed ethAddress, bytes32 name, uint256 role);
    event UserRoleReassigned(address indexed ethAddress, bytes32 name, uint256 role);

    /// @notice User information structure
    struct UserInfo {
        bytes32 name;
        bytes32 location;
        address ethAddress;
        Roles role;
    }

    mapping(address => UserInfo) private userDetails;
    address[] private users;

    /// @dev Register a new user by the owner
    function registerUser(
        address ethAddress,
        bytes32 name,
        bytes32 location,
        uint256 role
    ) public onlyOwner {
        require(
            userDetails[ethAddress].role == Roles.NoRole,
            "User already registered."
        );
        userDetails[ethAddress] = UserInfo({
            name: name,
            location: location,
            ethAddress: ethAddress,
            role: Roles(role)
        });
        users.push(ethAddress);
        emit UserRegistered(ethAddress, name);
    }

    /// @dev Revoke a user's role
    function revokeRole(address userAddress) public onlyOwner {
        require(
            userDetails[userAddress].role != Roles.NoRole,
            "User not registered."
        );
        emit UserRoleRevoked(
            userAddress,
            userDetails[userAddress].name,
            uint256(userDetails[userAddress].role)
        );
        userDetails[userAddress].role = Roles.Revoke;
    }

    /// @dev Reassign a user's role
    function reassignRole(address userAddress, uint256 role) public onlyOwner {
        require(
            userDetails[userAddress].role != Roles.NoRole,
            "User not registered."
        );
        userDetails[userAddress].role = Roles(role);
        emit UserRoleReassigned(
            userAddress,
            userDetails[userAddress].name,
            uint256(userDetails[userAddress].role)
        );
    }

    /// @dev Get user information
    function getUserInfo(address user)
        public
        view
        returns (
            bytes32 name,
            bytes32 location,
            address ethAddress,
            Roles role
        )
    {
        UserInfo memory info = userDetails[user];
        return (info.name, info.location, info.ethAddress, info.role);
    }

    /// @dev Get the total number of registered users
    function getUsersCount() public view returns (uint256) {
        return users.length;
    }

    /// @dev Get a user by index
    function getUserByIndex(uint256 index)
        public
        view
        returns (
            bytes32 name,
            bytes32 location,
            address ethAddress,
            Roles role
        )
    {
        return getUserInfo(users[index]);
    }

    /********************************************** Supplier Section ******************************************/
    mapping(address => address[]) private supplierRawProducts;

    event RawSupplyInitiated(
        address indexed productId,
        address indexed supplier,
        address shipper,
        address indexed receiver
    );

    /// @dev Create a new raw materials package
    function createRawPackage(
        bytes32 description,
        bytes32 farmerName,
        bytes32 location,
        uint256 quantity,
        address shipper,
        address receiver
    ) public {
        require(
            userDetails[msg.sender].role == Roles.Supplier,
            "Only a supplier can call this function."
        );

        RawMaterials rawData = new RawMaterials(
            msg.sender,
            description,
            farmerName,
            location,
            quantity,
            shipper,
            receiver
        );

        supplierRawProducts[msg.sender].push(address(rawData));
        emit RawSupplyInitiated(address(rawData), msg.sender, shipper, receiver);
    }

    /// @dev Get the number of raw packages created by a supplier
    function getPackagesCountS() public view returns (uint256) {
        require(
            userDetails[msg.sender].role == Roles.Supplier,
            "Only a supplier can call this function."
        );
        return supplierRawProducts[msg.sender].length;
    }

    /// @dev Get the package ID by index
    function getPackageIdByIndexS(uint256 index)
        public
        view
        returns (address)
    {
        require(
            userDetails[msg.sender].role == Roles.Supplier,
            "Only a supplier can call this function."
        );
        return supplierRawProducts[msg.sender][index];
    }

    /********************************************** Transporter Section ******************************************/
    function loadConsignment(
        address packageId,
        uint256 transporterType,
        address contractId
    ) public {
        require(
            userDetails[msg.sender].role == Roles.Transporter,
            "Only a transporter can call this function."
        );
        require(transporterType > 0, "Transporter type must be defined.");

        if (transporterType == 1) {
            RawMaterials(packageId).pickPackage(msg.sender);
        } else if (transporterType == 2) {
            Madicine(packageId).pickPackage(msg.sender);
        } else if (transporterType == 3) {
            MadicineW_D(contractId).pickWD(packageId, msg.sender);
        } else if (transporterType == 4) {
            MadicineD_P(contractId).pickDP(packageId, msg.sender);
        }
    }

    /********************************************** Manufacturer Section ******************************************/
    mapping(address => address[]) private rawPackagesAtManufacturer;

    function rawPackageReceived(address packageId) public {
        require(
            userDetails[msg.sender].role == Roles.Manufacturer,
            "Only a manufacturer can call this function."
        );

        RawMaterials(packageId).receivedPackage(msg.sender);
        rawPackagesAtManufacturer[msg.sender].push(packageId);
    }

    function getPackagesCountM() public view returns (uint256) {
        require(
            userDetails[msg.sender].role == Roles.Manufacturer,
            "Only a manufacturer can call this function."
        );
        return rawPackagesAtManufacturer[msg.sender].length;
    }

    function getPackageIdByIndexM(uint256 index)
        public
        view
        returns (address)
    {
        require(
            userDetails[msg.sender].role == Roles.Manufacturer,
            "Only a manufacturer can call this function."
        );
        return rawPackagesAtManufacturer[msg.sender][index];
    }
}
