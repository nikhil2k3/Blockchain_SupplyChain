// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Madicine.sol";

contract MadicineD_P {
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

    function pickDP(address _batchId, address _shipper) public {
        require(
            _shipper == package.shipper,
            "Only the associated shipper can pick the package."
        );
        require(
            package.status == PackageStatus.AtCreator,
            "Package must be in 'AtCreator' state to be picked."
        );

        package.status = PackageStatus.Picked;

        Madicine(_batchId).sendDP(
            package.receiver,
            package.sender
        );
    }

    function receiveDP(address _batchId, address _receiver) public {
        require(
            _receiver == package.receiver,
            "Only the associated receiver can receive the package."
        );
        require(
            package.status == PackageStatus.Picked,
            "Package must be picked before it can be delivered."
        );

        package.status = PackageStatus.Delivered;

        Madicine(_batchId).receiveDP(_receiver);
    }

    function getBatchIDStatus() public view returns (uint256) {
        return uint256(package.status);
    }
}
