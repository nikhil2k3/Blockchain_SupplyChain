// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RawMaterials {
    address public owner;

    enum PackageStatus {
        AtCreator,
        Picked,
        Delivered
    }

    struct Package {
        bytes32 productId;
        bytes32 description;
        bytes32 farmerName;
        bytes32 location;
        uint256 quantity;
        address shipper;
        address manufacturer;
        address supplier;
        PackageStatus status;
    }

    Package public package;

    event ShipmentUpdate(
        address indexed batchId,
        address indexed shipper,
        address indexed manufacturer,
        uint256 transporterType,
        uint256 status
    );

    constructor(
        address _supplier,
        bytes32 _description,
        bytes32 _farmerName,
        bytes32 _location,
        uint256 _quantity,
        address _shipper,
        address _manufacturer
    ) {
        owner = _supplier;
        package = Package({
            productId: bytes32(uint256(uint160(address(this)))),
            description: _description,
            farmerName: _farmerName,
            location: _location,
            quantity: _quantity,
            shipper: _shipper,
            manufacturer: _manufacturer,
            supplier: _supplier,
            status: PackageStatus.AtCreator
        });
    }

    function pickPackage(address _shipper) public {
        require(_shipper == package.shipper, "Only the assigned shipper can pick the package.");
        require(package.status == PackageStatus.AtCreator, "Package must be at creator stage.");
        package.status = PackageStatus.Picked;

        emit ShipmentUpdate(address(this), package.shipper, package.manufacturer, 1, uint256(package.status));
    }

    function receivedPackage(address _manufacturer) public {
        require(_manufacturer == package.manufacturer, "Only the manufacturer can receive the package.");
        require(package.status == PackageStatus.Picked, "Package must be picked first.");
        package.status = PackageStatus.Delivered;

        emit ShipmentUpdate(address(this), package.shipper, package.manufacturer, 1, uint256(package.status));
    }
}
