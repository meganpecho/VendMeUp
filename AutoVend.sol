pragma solidity ^0.4.17;

/* AutoVend
 * contract for physical vending machine 
 * _creator   = contract owner
 * _inventory = inventory
 */
contract AutoVend {
    // automated vending machine contract
    address  _creator;
    address private _coinStorage;
    bool    private _testMode;
    bool    private _running;
    uint32  private _stgIdx;
    uint8   STORAGE_MAX = 6;
    
    struct Item {
      string  name;
      uint256 cost;
      uint32  cnt;        
      address supplier;
      //function(address) external resupply; //NOTE: not possible?
    }
    
    struct store { 
        //NOTE: This doesn't corrently allow for a store[] to hold items. See inventory note.
      Item item; 
      bool locked;
      bool isActive;
    }
    
    store[6] private stg;
    mapping(address => uint32) private resupplyAddress;
    
    // getters
    function getResupplier() private returns (address) {
        
    }
    
    
    function AutoVend(uint8 itemCnt,
                      uint256 balance,
                      bool testMode) 
    public {
      _coinStorage = address(balance);
      _creator  = msg.sender; 
      _testMode = testMode; //made bool, should be bool?
      _stgIdx   = 0;
      // test storage contract 
      
      Item memory a = Item("gum", 3000, 20, 0x000000);
      // bytes memory __store;
      // _inv = Inventory(__store);
      // connect the vending machine to le blockchainz
      // this.goLive();
      _running  = true;
    }
    
    function _addItem(Item _item) internal {
      if (_stgIdx < 4) { // if we are not at max items
        bool success = false;
        for (uint32 i = 0; i < STORAGE_MAX; i++) {
          if(!stg[i].item.isActive) {
            stg[i].isActive  = true;
            stg[i].item      = _item;
            success                = true;
          } 
        }
        // if failed to add to array
        if(!success) {
          // shit be fucked, u no add:: maybe resize array
          // TODO: !!!! refund user !!!
          revert();
        }
      } 
    }
    // NOTE: For unlock, lock, and remove we take in a storeIdx as uint8,
    //       but pass them items in use. 
    function _unlock_store(uint32 storeIdx) internal {
      // make api call to physical device
      stg[storeIdx].locked = false;
      // currently dysfunctional while store struct is dysfunctional. as is checks if item is locked. 
    }
    
    function _lock_store(uint32 storeIdx) internal {
      // make api call to physical device
      stg[storeIdx].locked = true;
    }
    
    function vend(Item _item, uint32 qty) external payable {
      // TODO: unlock storage => vend qty item
      // update item state
      if (qty > _item.cnt) {
        _unlock_store(this.find(_item));
        // TODO: vend here
        _item.cnt-=qty;
        _lock_store(this.find(_item));
      }
      // handles removing item if item wont be restocked
      needResupply(_item); 
    }
    
    function needResupply(Item _item) internal {
      if (_item.cnt == 0) {
        resupply(_item);
      } else if (_item.cnt == uint8(-1)) {
        this.remove(_item); //sends an item, but remove() takes an storeIdx. 
      }
    }
    
    function find(Item _item) external returns (uint32)  {
        for (uint32 i = 0; i < STORAGE_MAX; i++) {
            if (stringsEqual(stg[i].item.name, _item.name)) {
                 return i;
            }
        }
    }
    
    function remove(Item _item) external {
        _remove(this.find(_item));
    }
    
    function _remove(uint32 storeIdx) internal { 
      //probably should take item, and find its storeIdx
      require(msg.sender == _creator);
      delete stg[storeIdx];
      // _inv.activeItems[storeIdx] = false;
      _stgIdx--;
    }
    
    function resupply(Item _item) internal {
      // TODO: call external resupply contract for item (at _item.resupply) 
      //_item.resupply(_item.supplier); //<< Do that  <<
    }
    
    function turnOff() external {
      require(msg.sender == _creator);
      _running = false;
    }
    // UTILITIES
    function stringsEqual(string _a, string _b) internal returns (bool) {
      return keccak256(_a) == keccak256(_b);
  }
}

// TODO: move into own file
//       populate the vending machine
/* contract vendMeUpFam {
  function popDefaultVendingMachine() {
    // TODO:
  }
} */
// NOTES:
// stock vending machine
// connect vending machine to ethereum network
