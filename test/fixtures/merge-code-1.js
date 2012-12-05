it("should have method #ss_coffee", function() {
  expect(b).to.respondTo("ss_merge");
  return expect(b.ss_merge).to.be.a("function");
});