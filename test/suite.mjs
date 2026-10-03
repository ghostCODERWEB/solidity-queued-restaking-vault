export async function suite(h) {
  const token = await h.token();
  const c = await h.deploy("QueuedStakeVault", [
    token.target,
    20,
    2000,
    h.addresses[0],
  ]);
  await h.tx(token.approve(c.target, 10000));
  await h.tx(c.deposit(1000, 1));
  await h.tx(c.requestExit(500000));
  await h.test("exit cannot complete early", () =>
    h.revert(() => c.completeExit(1, 0)),
  );
  await h.test("only owner slashes", () =>
    h.revert(() => c.connect(h.signers[1]).slash(1000, h.addresses[2])),
  );
  await h.test("slash rate capped per call", () =>
    h.revert(() => c.slash(2001, h.addresses[2])),
  );
  await h.test("pending shares remain exposed to loss", async () => {
    const before = await c.previewRedeem(500000);
    await h.tx(c.slash(1000, h.addresses[2]));
    h.ok((await c.previewRedeem(500000)) < before);
  });
  await h.test("wrong owner cannot complete exit", async () => {
    await h.mine(21);
    await h.revert(() => c.connect(h.signers[1]).completeExit(1, 0));
  });
  await h.test("completion burns escrowed shares exactly once", async () => {
    await h.tx(c.completeExit(1, 0));
    h.eq((await c.exits(1)).completed, true);
    await h.revert(() => c.completeExit(1, 0));
  });
}
