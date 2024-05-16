// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@pythnetwork/pyth-sdk-solidity/IPyth.sol";

interface IBand {
    function getReferenceData(string memory _base, string memory _quote) external view returns (ReferenceData memory);
}

struct ReferenceData {
    uint256 rate; // base/quote exchange rate, multiplied by 1e18.
    uint256 lastUpdatedBase; // UNIX epoch of the last time when base price gets updated.
    uint256 lastUpdatedQuote; // UNIX epoch of the last time when quote price gets updated.
}

contract PriceFeedExt {
    address public gov;
    uint8 public decimals = 8;
    string public description;

    bool public bBandUse = false; // false: Pyth Usage, true: Band Usage

    IPyth public pythNetwork;
    uint public maxPythPriceAge;
    bytes32 public pythPriceId;

    IBand public bandProtocol;
    string public bandPriceBase;
    string public bandPriceQuote;

    int256 answer;

    modifier onlyGov() {
        require(msg.sender == gov, "Not Governor");
        _;
    }

    constructor (string memory _description, uint8 _decimals) {
        gov = msg.sender;

        description = _description;
        decimals = _decimals;
    }

    function initialize(
        bool _bBandUse,

        IPyth _pythNetwork,
        uint _maxPythPriceAge,
        bytes32 _pythPriceId,

        IBand _bandProtocol,
        string memory _bandPriceBase,
        string memory _bandPriceQuote
    ) external onlyGov {
        bBandUse = _bBandUse;

        pythNetwork = _pythNetwork;
        maxPythPriceAge = _maxPythPriceAge;
        pythPriceId = _pythPriceId;

        bandProtocol = _bandProtocol;
        bandPriceBase = _bandPriceBase;
        bandPriceQuote = _bandPriceQuote;
    }

    function setGov(address newGov) external onlyGov {
        require(gov != newGov, "Already Set");
        gov = newGov;
    }

    function setDescription(string calldata newDescription) external onlyGov {
        description = newDescription;
    }

    function setDecimals(uint8 newDecimals) external onlyGov {
        require(decimals != newDecimals, "Already Set");
        decimals = newDecimals;
    }

    function latestAnswer() external view returns (int256) {
        if (!bBandUse) {
            require(address(pythNetwork) != address(0), "PriceFeedExt: pyth network address is not configured");
            require(pythPriceId != bytes32(0), "PriceFeedExt: price id not configured for given token");
            PythStructs.Price memory priceDataByPyth = pythNetwork.getPriceNoOlderThan(pythPriceId, maxPythPriceAge);
            require(priceDataByPyth.price > 0, "PriceFeedExt: pyth invalid price");
            uint32 priceExponent = uint32(-priceDataByPyth.expo);

            return int256(uint256(int256(int64(priceDataByPyth.price))) * (10 ** decimals) / (10 ** priceExponent));
        } else {
            require(address(bandProtocol) != address(0), "PriceFeedExt: band protocol address is not configured");
            require(bytes(bandPriceBase).length != 0, "PriceFeedExt: pand price base not configured for given token");
            require(bytes(bandPriceQuote).length != 0, "PriceFeedExt: pand price quote not configured for given token");
            ReferenceData memory priceDataByBand = bandProtocol.getReferenceData(bandPriceBase, bandPriceQuote);
            require(priceDataByBand.rate > 0, "PriceFeedExt: band invalid price");

            return int256(priceDataByBand.rate * (10 ** decimals) / 1e18);
        }
    }

    function setBandUse(bool _bBandUse) external onlyGov {
        bBandUse = _bBandUse;
    }

    function setPythNetwork(IPyth _pythNetwork) external onlyGov {
        pythNetwork = _pythNetwork;
    }

    function setMaxPythPriceAge(uint _maxPythPriceAge) external onlyGov {
        maxPythPriceAge = _maxPythPriceAge;
    }

    function setPythPriceId(bytes32 _priceId) external onlyGov {
        pythPriceId = _priceId;
    }

    function setBandProtocol(IBand _bandProtocol) external onlyGov {
        bandProtocol = _bandProtocol;
    }

    function setBandPriceBase(string memory _bandPriceBase) external onlyGov {
        bandPriceBase = _bandPriceBase;
    }

    function setBandPriceQuote(string memory _bandPriceQuote) external onlyGov {
        bandPriceQuote = _bandPriceQuote;
    }
}