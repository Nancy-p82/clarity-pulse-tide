import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensure that only owner can create events",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get("deployer")!;
    const user1 = accounts.get("wallet_1")!;

    let block = chain.mineBlock([
      Tx.contractCall(
        "pulse-tide",
        "create-event",
        [types.utf8("Test Event")],
        user1.address
      )
    ]);
    
    block.receipts[0].result.expectErr(100);
  },
});

Clarinet.test({
  name: "Ensure users can submit feedback only once per event",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get("deployer")!;
    const user1 = accounts.get("wallet_1")!;

    let block = chain.mineBlock([
      Tx.contractCall(
        "pulse-tide",
        "create-event",
        [types.utf8("Test Event")],
        deployer.address
      ),
      Tx.contractCall(
        "pulse-tide",
        "submit-feedback",
        [types.uint(0), types.uint(5)],
        user1.address
      ),
      Tx.contractCall(
        "pulse-tide",
        "submit-feedback",
        [types.uint(0), types.uint(4)],
        user1.address
      )
    ]);
    
    block.receipts[0].result.expectOk();
    block.receipts[1].result.expectOk();
    block.receipts[2].result.expectErr(102);
  },
});
