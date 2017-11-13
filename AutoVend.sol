/* vendMeUp
 * John Pridmore, Artur Oganezov, Megan Pecho
 * 11/14/17
 * CSC299
 *
 * AutoVend
 * contract for physical vending machine
 * _creator   = contract owner
 * _inventory = inventory
 */
pragma solidity ^0.4.17;
contract AutoVend {
    // automated vending machine contract
    address _creator;
    address private _coinStorage;
    bool    private _testMode;
    bool    private _running;
    uint32  _stgIdx;
    uint8   STORAGE_MAX = 6;

    struct Item {
      string  name;
      uint256 cost;
      uint32  cnt;
      address supplier;
      uint32  idx;
    }
    // store represents physical containers for Items
    struct store {
      Item item;
      bool locked;
      bool isActive;
    }
    store[6] private stg;

    /* CTOR */
    function AutoVend(bool testMode) public payable {
        _creator  = msg.sender;
        _testMode = testMode; //made bool, should be bool?
        _stgIdx   = 0;
        _running  = true;
    // test storage contract
    //   for(; _stgIdx < STORAGE_MAX; _stgIdx++) {
    //       stg[_stgIdx].item = Item("", 0, 0, 0x000000, _stgIdx);
    //   }
    }

    /* addItem */
    function addItem(uint32 _idx, string _name, uint256 _cost, uint32 _cnt, address _supplier) public {
        while(stg[_idx].isActive && _idx < STORAGE_MAX) {
            _idx++;
        }
        if (_idx >= STORAGE_MAX) {
            /* @todo REVERT */

        }
        Item memory tmp = Item({name:     _name,
                                cost:     _cost,
                                cnt:      _cnt,
                                supplier: _supplier,
                                idx:      _idx});
        stg[_idx].item = tmp;
        stg[_idx].isActive = true;
        /* @todo change so that things are much more readable?*/
        _stgIdx = _idx;
    }

    /* get Item
     * @NOTE: does not work currently because can't return array of structs
    function getItem(uint32 itemIdx) external view returns (Item) {
        return stg[itemIdx].item;
    } */

    /* change Item */
    function changeItem(uint32 itemIdx, string _name, uint256 _cost, uint32 _cnt, address _supplier) external {
        require(msg.sender == stg[itemIdx].item.supplier);
        /* TODO: change item logic */
        addItem(itemIdx, _name, _cost, _cnt, _supplier);
    }

    /* removeItem
     * removes item and sets storage space to inactive
     * @arg itemidx   (uint32)  item's index in storage array
     * @arg _name     (string)  name of item
     * @arg _cost     (uint256) cost of item
     * @arg _cnt      (uint32)  no. items in stock
     * @arg _supplier (address) the hex address of the item's supplier
     */
    function removeItem(uint32 itemIdx) external {
        if (msg.sender != stg[itemIdx].item.supplier && msg.sender != _creator) {
            revert();
        }
        stg[itemIdx].item.name = ""; stg[itemIdx].item.cost = 0;
        stg[itemIdx].item.cnt = 0; stg[itemIdx].item.supplier = 0x0;
        stg[itemIdx].item.idx = itemIdx;
        stg[itemIdx].isActive = false;
    }

     /* remove item and replace with new one
     * @arg itemidx   (uint32)  item's index in storage array
     * @arg _name     (string)  name of item
     * @arg _cost     (uint256) cost of item
     * @arg _cnt      (uint32)  no. items in stock
     * @arg _supplier (address) the hex address of the item's supplier
     */
    function removeItem(uint32  itemIdx,
                        string  _name,
                        uint256 _cost,
                        uint32  _cnt,
                        address _supplier) external {
        if (msg.sender != stg[itemIdx].item.supplier && msg.sender != _creator) {
            revert();
        }
        stg[itemIdx].item.name = ""; stg[itemIdx].item.cost = 0;
        stg[itemIdx].item.cnt = 0; stg[itemIdx].item.supplier = 0x0;
        stg[itemIdx].item.idx = itemIdx;
        addItem(itemIdx, _name, _cost, _cnt, _supplier);
        // @TODO test?
    }

    /* vend
     * vends item to customer
     * @arg idx (uint32) desired item's index in storage array
     * @arg qty (uint32) number of items to vend
     */
    function vend(uint32 idx, uint32 qty) external payable returns (bool) {
        require(stg[idx].isActive);
        if (stg[idx].item.cnt >= qty) {
            stg[idx].item.cnt -= qty;
            // @TODO vend/interact with the storage location?
        } else { // @TODO need to give refund to the
            revert(); // call for resupply?
        }
    }

    function turnOff() external {
      require(msg.sender == _creator);
      _running = false;
    }

    // UTILITIES
    /* quick fix to compare strings */
    function stringsEqual(string _a, string _b) internal pure returns (bool) {
      return keccak256(_a) == keccak256(_b);
    }

    /* convert bytes32 to string */
    function bytes32ToString(bytes32 x) internal pure returns (string a) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }
}
// NOTES:
    /* Auxiliary Fxns that currently have no use */
    // function find(Item _item) internal view returns (uint16)  {
    //     for (uint16 i = 0; i < STORAGE_MAX; i++) {
    //         if (stringsEqual(stg[i].item.name, _item.name)) {
    //              return i;
    //         }
    //     }
    // }


    // function needResupply(Item _item) internal {
    //   if (_item.cnt == 0) {
    //     resupply(_item);
    //   } else if (_item.cnt == uint8(-1)) {
    //     this.remove(_item); //sends an item, but remove() takes an storeIdx.
    //   }
    // }

    // function resupply(Item _item) internal {
    //   // TODO: call external resupply contract for item (at _item.resupply)
    //   //_item.resupply(_item.supplier); //<< Do that  <<
    // }
