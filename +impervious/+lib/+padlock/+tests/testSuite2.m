function test_suite = testSuite2()
initTestSuite;
end


function goldpath = setup()
goldpath = padlock.tests.getDataPath();
end


function teardown(goldpath)
end


function testReadStatus(goldpath)
goldfile = [goldpath '/locked.gold'];
stats = @(x)padlock.tests.StatusCodes(x);

genStatus = padlock.getLockStatus(goldfile, stats);
assertEqual(padlock.tests.StatusCodes.LOCKED, genStatus);
end


function testReadBadStatus(goldpath)
goldfile = [goldpath '/undefined.gold'];
stats = @(x)padlock.tests.StatusCodes(x);

f = @()padlock.getLockStatus(goldfile, stats);
assertExceptionThrown(f,'MATLAB:class:InvalidEnum');
end