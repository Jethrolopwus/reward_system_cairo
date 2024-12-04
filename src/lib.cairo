use core::starknet::ContractAddress;
#[starknet::interface]
pub trait IHelloStarknet<TContractState> {
    
    fn increase_balance(ref self: TContractState, amount: felt252);
    fn get_balance(self: @TContractState) -> felt252;
    fn add_points(ref self: TContractState, address: ContractAddress, points: u128);
    fn get_points(ref self: TContractState, amount: u128)->u128;
}

#[starknet::contract]
mod RewardSystem {
    use starknet::event::EventEmitter;
use core::starknet::{ ContractAddress, get_caller_address};
    use core::starknet::storage::{Map, StoragePointerReadAccess, StoragePointerWriteAccess, StoragePathEntry};
    
    #[storage]
    struct Storage {
        balance: felt252,
        userPoints: Map<ContractAddress, u128>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event{
    AddPoint: AddPoint,
    RedeemPoint: RedeemPoint,
    }

    #[derive(Drop, starknet::Event)]
    pub struct AddPoint {
       owner:ContractAddress,
       point: u128,
    }

    #[derive(Drop, starknet::Event)]
    pub struct RedeemPoint {
       owner:ContractAddress,
       point: u128,
    }

    #[abi(embed_v0)]
    impl HelloStarknetImpl of super::IHelloStarknet<ContractState> {
        fn increase_balance(ref self: ContractState, amount: felt252) {
            assert(amount != 0, 'Amount cannot be 0');
            self.balance.write(self.balance.read() + amount);
        }

        fn get_balance(self: @ContractState) -> felt252 {
           return self.balance.read();
        }
         fn add_points(ref self: ContractState, address: ContractAddress , points: u128)
         {
          let caller = get_caller_address();
         let previousPoint = self.userPoints.entry(caller).read();
         self.userPoints.entry(caller).write(previousPoint +points);
         self.emit(AddPoint{
            owner:caller,
            point: points

         })

         }
         fn get_points(ref self: ContractState, amount: u128) -> u128{
         assert(amount != 0, 'Amount cannot be 0');
         let caller = get_caller_address();
         let points = self.userPoints.entry(caller).read() - amount;
         self.emit(RedeemPoint{
            owner:caller,
            point:points
         });

         return points; 

         }
    }
}
