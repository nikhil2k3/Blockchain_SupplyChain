// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Madicine {
    enum MadicineStatus {
        AtCreator,
        PickedForWholesaler,
        DeliveredToWholesaler,
        PickedForDistributor,
        DeliveredToDistributor,
        PickedForPharma,
        DeliveredToPharma
    }

    address public owner;

    struct Batch {
        address manufacturer;
        address shipper;
        address wholesaler;
        address distributor;
        address pharma;
        MadicineStatus status;
    }

    Batch public batch;

    constructor(
        address _manufacturer,
        address _shipper,
        address _receiver,
        uint256 _receiverType
    ) {
        owner = _manufacturer;
        batch.manufacturer = _manufacturer;
        batch.shipper = _shipper;

        if (_receiverType == 1) {
            batch.wholesaler = _receiver;
            batch.status = MadicineStatus.PickedForWholesaler;
        } else if (_receiverType == 2) {
            batch.distributor = _receiver;
            batch.status = MadicineStatus.PickedForDistributor;
        }
    }

    function pickPackage(address _shipper) public {
        require(_shipper == batch.shipper, "Only the assigned shipper can pick the package.");
        require(batch.status == MadicineStatus.AtCreator, "Package must be at creator stage to be picked.");

        if (batch.wholesaler != address(0)) {
            batch.status = MadicineStatus.PickedForWholesaler;
        } else if (batch.distributor != address(0)) {
            batch.status = MadicineStatus.PickedForDistributor;
        }
    }

    function sendWD(address _receiver, address _sender) public {
        require(_sender == batch.wholesaler, "Only the wholesaler can send the package to the distributor.");
        batch.distributor = _receiver;
        batch.status = MadicineStatus.PickedForDistributor;
    }

    function receivedWD(address _receiver) public {
        require(_receiver == batch.distributor, "Only the distributor can mark this as received.");
        batch.status = MadicineStatus.DeliveredToDistributor;
    }

    function sendDP(address _receiver, address _sender) public {
        require(_sender == batch.distributor, "Only the distributor can send the package to pharma.");
        batch.pharma = _receiver;
        batch.status = MadicineStatus.PickedForPharma;
    }

    function receiveDP(address _receiver) public {
        require(_receiver == batch.pharma, "Only the pharma can mark this as received.");
        batch.status = MadicineStatus.DeliveredToPharma;
    }
}
