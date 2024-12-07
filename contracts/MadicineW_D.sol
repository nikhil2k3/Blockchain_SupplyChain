// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Madicine.sol";

contract MadicineW_D {
    address public owner;

    enum PackageStatus {
        AtCreator,
        Picked,
        Delivered
    }

    struct Package {
        address batchId;
        address sender;
        address shipper;
        address receiver;
        PackageStatus status;
    }

    Package public package;

    constructor(
        address _batchId,
        address _sender,
        address _shipper,
        address _receiver
    ) {
        owner = _sender;
        package = Package({
            batchId: _batchId,
            sender: _sender,
            shipper: _shipper,
            receiver: _receiver,
            status: PackageStatus.AtCreator
        });
    }

    function pickWD(address _batchId, address _shipper) public {
        require(
            _shipper == package.shipper,
            "Only the assigned shipper can pick the package."
        );
        require(
            package.status == PackageStatus.AtCreator,
            "Package must be at creator stage."
        );
        package.status = PackageStatus.Picked;

        Madicine(_batchId).sendWD(package.receiver, package.sender);
    }

    function receiveWD(address _batchId, address _receiver) public {
        require(
            _receiver == package.receiver,
            "Only the assigned receiver can receive the package."
        );
        require(
            package.status == PackageStatus.Picked,
            "Package must be picked first."
        );
        package.status = PackageStatus.Delivered;

        Madicine(_batchId).receivedWD(_receiver);
    }

    function getBatchIDStatus() public view returns (uint256) {
        return uint256(package.status);
    }
}
