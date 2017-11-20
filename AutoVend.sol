/* vendMeUp
 * John Pridmore, Artur Oganezov, Megan Pecho
 * 11/14/17
 * CSC299
 */
pragma solidity ^0.4.17;
contract AutoVend {
    // member vars
    address private _creator;       /* creator of this vending machine */
    address private _coinStorage;   /* cold wallet for machine */
    bool    private _testMode;      /* is machine in test mode? */
    bool    private _running;       /* is machine currently running? */
    uint32  _stgIdx;                /* index of latest, still active item */
    uint8   STORAGE_MAX = 6;        /* max number of phys. containers allowed */

    struct Item {
      string  name;          /* the name of the item */
      uint256 cost;          /* the cost of ea. item */
      uint32  cnt;           /* the number of items in the machine  */
      address supplier;      /* the address of the item's supplier  */
      uint32  idx;           /* the index in the store[] item is in */
    }

    struct store {
      Item item;      /* the item to be stored                               */
      bool locked;    /* whether this storage container is locked            */
      bool isActive;  /* whether this storage container's item can be vended */
    }

    // @NOTE: if you make stg public it fucks all the things up
    store[6] private stg; /* array of storage structs to contain items */

    //Checks if the machine is on, and the item is active
    modifier isVendOk(uint32 idx, uint32 qty) {
        require(_running);
        require(stg[idx].isActive);
        require(stg[idx].item.cnt > 0);
        require(stg[idx].item.cnt >= qty);
        _;
    }

    //Checks if machine is on
    modifier isOn() {
        require(_running);
        _;
    }

    modifier onlyBy(address _accnt) {
      require(msg.sender == _accnt);
      _;
    }


    /* Default ctor
     * @arg AutoVend
     * @arg contract for physical vending machine
     * @arg bool _testMode  = if machine is being tested
     */
    function AutoVend(bool testMode) public payable {
        _creator  = msg.sender;
        _testMode = testMode;
        _stgIdx   = 0;
        _running  = true;
        for (uint8 i = 0; i < STORAGE_MAX; i++) {
          stg[i].isActive = false;
        }
    }

    /* addItem
     * @arg uint32  _idx:      the index in stg (storage) to which item is added
     * @arg string  _name:     the name of the item to be added
     * @arg uint256 _cost:     the cost of the item to be added
     * @arg uint32  _cnt:      the number of items
     * @arg address _supplier: the supplier of the item
     */
    function addItem(uint32 _idx,
                     string _name,
                     uint256 _cost,
                     uint32 _cnt,
                     address _supplier) isOn onlyBy(_creator) public {
        
        Item memory tmp = Item({name:     _name,
                                cost:     _cost,
                                cnt:      _cnt,
                                supplier: _supplier,
                                idx:      _idx});
        stg[_idx].item = tmp;
        stg[_idx].isActive = true;
        _stgIdx = _idx;
    }

    /* get Item
     * @NOTE: does not work currently because can't return array of structs
    function getItem(uint32 itemIdx) external view returns (Item) {
        return stg[itemIdx];
    } */

    /* change Item
     * @arg uint32  _idx:      the index in stg (storage) to which item is added
     * @arg string  _name:     the name of the item to be added
     * @arg uint256 _cost:     the cost of the item to be added
     * @arg uint32  _cnt:      the number of items
     * @arg address _supplier: the supplier of the item
     */
    function changeItem(uint32 itemIdx, string _name, uint256 _cost, uint32 _cnt, address _supplier) isOn external {
        require(msg.sender == stg[itemIdx].item.supplier);
        // @note: sanity check to ensure old item's information doesn't bleed over
        stg[itemIdx].item.name     = "";
        stg[itemIdx].item.cost     = 0;
        stg[itemIdx].item.cnt      = 0;
        stg[itemIdx].item.supplier = 0x0;
        stg[itemIdx].item.idx      = itemIdx;
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
    function removeItem(uint32 itemIdx) isOn external {
        if (msg.sender != stg[itemIdx].item.supplier && msg.sender != _creator){
            revert();
        }
        stg[itemIdx].item.name     = "";
        stg[itemIdx].item.cost     = 0;
        stg[itemIdx].item.cnt      = 0;
        stg[itemIdx].item.supplier = 0x0;
        stg[itemIdx].item.idx      = itemIdx;
        stg[itemIdx].isActive      = false;
    }

     /* Duplicate
     * remove item and replace with new one
     *  @arg itemidx   (uint32)  item's index in storage array
     *  @arg _name     (string)  name of item
     *  @arg _cost     (uint256) cost of item
     *  @arg _cnt      (uint32)  no. items in stock
     *  @arg _supplier (address) the hex address of the item's supplier
     */
    // function removeItem(uint32  itemIdx,
    //                     string    _name,
    //                     uint256   _cost,
    //                     uint32    _cnt,
    //                     address   _supplier) on external {
    //     if (msg.sender != stg[itemIdx].item.supplier && msg.sender != _creator) {
    //         revert();
    //     }
    //     stg[itemIdx].item.name = ""; stg[itemIdx].item.cost = 0;
    //     stg[itemIdx].item.cnt = 0; stg[itemIdx].item.supplier = 0x0;
    //     stg[itemIdx].item.idx = itemIdx;
    //     addItem(itemIdx, _name, _cost, _cnt, _supplier);
    //     // @TODO test?
    // }


    //Event that signifies vending.
    event vending(
        uint32 _qty,
        string _name,
        uint256 _cost,
        uint32 _cnt
    );

    /* vend
     * vends item to customer
     * @arg idx (uint32) desired item's index in storage array
     * @arg qty (uint32) number of items to vend
     */
    function vend(uint32 idx, uint32 qty) external isOn isVendOk(idx, qty) payable returns (bool) {
        uint256 tot_val = checkMulOverflow(stg[idx].item.cost, uint(qty));
        if (tot_val == 0) {
            revert();
        }
        require(msg.value >= tot_val);
        /* @todo: percentage for contract creator? */
        if (stg[idx].item.cnt >= qty) {
            stg[idx].item.cnt -= qty;
            stg[idx].item.supplier.transfer(msg.value);
            vending(qty, stg[idx].item.name, stg[idx].item.cost, stg[idx].item.cnt);
            //make sure JS doesn't do same check as above on cnt, cnt has already been subtracted from.
        } else {
            revert(); // call for resupply?
        }
        if (stg[idx].item.cnt <= 0) {
            stg[idx].isActive = false;
        }
    }

    /* turnOff
     * turns off the vending machine so that it can't vend
     */
    function turnOff() external {
      require(msg.sender == _creator);
      _running = false;
      for(uint32 i = 0; i < STORAGE_MAX; i++) {
        stg[i].isActive = false;
      }
      // @todo? destroy(this);
    }

    /* ------------------------------UTILITIES------------------------------ */

    /* checkAddOverflow
     * checks if integer addition between two 
     */
    function checkAddOverflow(uint a, uint b) internal pure returns (uint) {
      if (a + b < a) {
        if (a >= b) {
          return a;
        } else {
          return b;
        }
      } else {
        return a + b;
      }
    }

    function checkMulOverflow(uint a, uint b) internal pure returns (uint) {
      uint256 UINT256_MAX = uint256(int256(-1));
      uint256 result = a * b;
      if (result > UINT256_MAX) {
        return 0;
      } else {
        return result & UINT256_MAX;
      }

    }
    /* stringsEqual
     * @TODO: find better way?
     * hashes both strings and returns their thing
     */
    function stringsEqual(string _a, string _b) internal pure returns (bool) {
      return keccak256(_a) == keccak256(_b);
    }

    /* bytes32Tostring
     * convert bytes32 to string
     * @TODO: cite stack overflow article?
     * @arg x 32bit array of bytes to be converted
     */
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
