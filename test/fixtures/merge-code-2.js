it("should merge javascript files", function() {
  return b.ss_merge([JS_CODE_1, JS_CODE_2], {}, function(err, str) {
    expect(err).to.be["null"];
    expect(str).to.have.string(COFFEEKUP_RESULT_1);
    return done();
  });
});