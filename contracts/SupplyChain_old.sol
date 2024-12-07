// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SupplyChainOld {
    address public owner;

    enum Roles {
        NoRole,
        Supplier,
        Transporter,
        Manufacturer,
        Wholesaler,
        Distributor,
        Pharma,
        Revoked
    }

    enum PackageStatus {
        AtCreator,
        Picked,
        Delivered
    }

    struct UserInfo {
        bytes32 name;
        bytes32 location;
        address ethAddress;
        Roles role;
    }

    mapping(address => UserInfo) public userDetails;
    address[] public users;

    struct RawProductInfo {
        bytes32 productId;
        bytes32 description;
        bytes32 farmerName;
        bytes32 location;
        uint256 quantity;
        address shipper;
        address receiver;
        address supplier;
        PackageStatus status;
    }

    mapping(bytes32 => RawProductInfo) public rawProductDetails;
    mapping(address => bytes32[]) public supplierRawProducts;

    event UserRegistered(address indexed ethAddress, bytes32 name);
    event UserRoleRevoked(address indexed ethAddress, bytes32 name, Roles role);
    event UserRoleReassigned(address indexed ethAddress, bytes32 name, Roles role);
    event RawSupplyInitiated(
        bytes32 indexed productId,
        address indexed supplier,
        address shipper,
        address indexed receiver
    );
    event ShipmentUpdated(
        bytes32 indexed batchId,
        address indexed shipper,
        address indexed receiver,
        uint256 transporterType,
        uint256 status
    );

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    modifier onlyRole(Roles requiredRole) {
        require(userDetails[msg.sender].role == requiredRole, "Unauthorized role.");
        _;
    }

    function registerUser(
        address ethAddress,
        bytes32 name,
        bytes32 location,
        uint256 role
    ) public onlyOwner {
        require(userDetails[ethAddress].role == Roles.NoRole, "User is already registered.");
        userDetails[ethAddress] = UserInfo({
            name: name,
            location: location,
            ethAddress: ethAddress,
            role: Roles(role)
        });
        users.push(ethAddress);
        emit UserRegistered(ethAddress, name);
    }

    function revokeRole(address userAddress) public onlyOwner {
        require(userDetails[userAddress].role != Roles.NoRole, "User not registered.");
        emit UserRoleRevoked(
            userAddress,
            userDetails[userAddress].name,
            userDetails[userAddress].role
        );
        userDetails[userAddress].role = Roles.Revoked;
    }

    function reassignRole(address userAddress, uint256 role) public onlyOwner {
        require(userDetails[userAddress].role != Roles.NoRole, "User not registered.");
        userDetails[userAddress].role = Roles(role);
        emit UserRoleReassigned(
            userAddress,
            userDetails[userAddress].name,
            userDetails[userAddress].role
        );
    }

    function supplyRawMaterials(
        bytes32 description,
        bytes32 farmerName,
        bytes32 location,
        uint256 quantity,
        address shipper,
        address receiver
    ) public onlyRole(Roles.Supplier) {
        bytes32 productId = keccak256(
            abi.encodePacked(msg.sender, block.number, quantity)
        );
        rawProductDetails[productId] = RawProductInfo({
            productId: productId,
            description: description,
            farmerName: farmerName,
            location: location,
            quantity: quantity,
            shipper: shipper,
            receiver: receiver,
            supplier: msg.sender,
            status: PackageStatus.AtCreator
        });
        supplierRawProducts[msg.sender].push(productId);
        emit RawSupplyInitiated(productId, msg.sender, shipper, receiver);
    }

    function pickPackage(bytes32 productId, address shipper) public {
        require(
            rawProductDetails[productId].shipper == shipper,
            "Unauthorized shipper."
        );
        require(
            rawProductDetails[productId].status == PackageStatus.AtCreator,
            "Package not at creator stage."
        );
        rawProductDetails[productId].status = PackageStatus.Picked;
        emit ShipmentUpdated(
            productId,
            shipper,
            rawProductDetails[productId].receiver,
            1,
            uint256(PackageStatus.Picked)
        );
    }

    function receivePackage(bytes32 productId, address receiver) public {
        require(
            rawProductDetails[productId].receiver == receiver,
            "Unauthorized receiver."
        );
        require(
            rawProductDetails[productId].status == PackageStatus.Picked,
            "Package not picked yet."
        );
        rawProductDetails[productId].status = PackageStatus.Delivered;
        emit ShipmentUpdated(
            productId,
            rawProductDetails[productId].shipper,
            receiver,
            1,
            uint256(PackageStatus.Delivered)
        );
    }

    function getUsersCount() public view returns (uint256) {
        return users.length;
    }

    function getUserByIndex(uint256 index) public view returns (UserInfo memory) {
        require(index < users.length, "Index out of bounds.");
        return userDetails[users[index]];
    }

    function getRawProductsBySupplier(address supplier) public view returns (bytes32[] memory) {
        return supplierRawProducts[supplier];
    }

    function getRawProductDetails(bytes32 productId)
        public
        view
        returns (RawProductInfo memory)
    {
        return rawProductDetails[productId];
    }
}
