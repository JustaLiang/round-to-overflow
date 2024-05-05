/// Module: fortune
module lesson4::fortune {

    // Dependencies

    use sui::coin::{Self, Coin, TreasuryCap};
    use sui::balance::{Self, Balance};
    use sui::url;

    // One Time Witness

    public struct FORTUNE has drop {}

    // Objects

    public struct Treasury has key {
        id: UID,
        cap: TreasuryCap<FORTUNE>,
    }

    public struct AdminCap has key, store {
        id: UID,
    }

    // Constructor

    fun init(otw: FORTUNE, ctx: &mut TxContext) {
        // create fungible token
        let url = url::new_unsafe_from_bytes(
            b"https://aqua-natural-grasshopper-705.mypinata.cloud/ipfs/Qmeyz3FijdgyR9AMqg84nzpQR4sXbZd1M4UBhQ9Dz99sYE"
        );
        let (cap, metadata) = coin::create_currency(
            otw,
            9,
            b"FTN",
            b"Fortune Coin",
            b"Collect Fortune to get special NFT",
            option::some(url),
            ctx,
        );

        // make metadata immutable
        transfer::public_freeze_object(metadata);

        // wrap TreasuryCap in Treasury and share
        let treasury = Treasury {
            id: object::new(ctx),
            cap,
        };
        transfer::share_object(treasury);

        // give AdminCap to deployer
        let admin_cap = AdminCap { id: object::new(ctx) };
        transfer::transfer(admin_cap, ctx.sender());
    }

    // Public funs

    public fun mint(
        treasury: &mut Treasury,
        _: &AdminCap,
        value: u64,
        ctx: &mut TxContext,
    ): Coin<FORTUNE> {
        coin::mint(&mut treasury.cap, value, ctx)
    }

    // Entry funs

    entry fun mint_to(
        treasury: &mut Treasury,
        cap: &AdminCap,
        value: u64,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        let coin = mint(treasury, cap, value, ctx);
        transfer::public_transfer(coin, recipient);
    }

    // Package funs

    public(package) fun burn(
        treasury: &mut Treasury,
        balance: Balance<FORTUNE>,
    ) {
        balance::decrease_supply(treasury.cap.supply_mut(), balance);
    }

}