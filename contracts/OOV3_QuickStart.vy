# pragma version ^0.4.0


# EscalationManagerSettings struct
struct EscalationManagerSettings:
    arbitrateViaEscalationManager: bool  # False if the DVM is used as an oracle (EscalationManager on True).
    discardOracle: bool  # False if Oracle result is used for resolving assertion after dispute.
    validateDisputers: bool  # True if the EM isDisputeAllowed should be checked on disputes.
    assertingCaller: address  # Stores msg.sender when assertion was made.
    escalationManager: address  # Address of the escalation manager (zero address if not configured).

# Assertion struct
struct Assertion:
    escalationManagerSettings: EscalationManagerSettings  # Settings related to the escalation manager.
    asserter: address  # Address of the asserter.
    assertionTime: uint256  # Time of the assertion (use uint256 instead of uint64 in Vyper).
    settled: bool  # True if the request is settled.
    currency: address  # Address of the ERC20 token used to pay rewards and fees.
    expirationTime: uint256  # Unix timestamp marking threshold when the assertion can no longer be disputed.
    settlementResolution: bool  # Resolution of the assertion (false till resolved).
    domainId: bytes32  # Optional domain that can be used to relate the assertion to others in the escalationManager.
    identifier: bytes32  # UMA DVM identifier to use for price requests in the event of a dispute.
    bond: uint256  # Amount of currency that the asserter has bonded.
    callbackRecipient: address  # Address that receives the callback.
    disputer: address  # Address of the disputer.


interface OptimisticOracleV3:
    def assertTruthWithDefaults(claim: Bytes[256], asserter: address) -> bytes32: nonpayable
    def settleAndGetAssertionResult(assertionId: bytes32) -> bool: nonpayable
    def getAssertionResult(assertionId: bytes32) -> bool: view
    def getAssertion(assertionId: bytes32) -> Assertion: view


oov3: OptimisticOracleV3 # Optimistic Oracle V3 instance

# Asserted claim. 
# This is some truth statement about the world and can be verified by the network of disputers.
assertedClaim: public(Bytes[256])

# Each assertion has an associated assertionID that uniquly identifies the assertion. 
# We will store this here.
assertionId: public(bytes32)


@deploy
def __init__():
    self.oov3 = OptimisticOracleV3(0xFd9e2642a170aDD10F53Ee14a93FcF2F31924944)
    self.assertedClaim = b"Argentina won the 2022 Fifa World Cup in Qatar"

@external
def assertTruth():
    """
    Assert the truth against the Optimistic Asserter. This uses the assertion with defaults method which defaults
    all values, such as a) challenge window to 7200 seconds (2 hrs), b) identifier to ASSERT_TRUTH, c) bond currency
    to USDC and c) and default bond size to 0 (which means we dont need to worry about approvals in this example).
    """
    self.assertionId = extcall self.oov3.assertTruthWithDefaults(self.assertedClaim, self)

@external
def settleAndGetAssertionResult() -> bool:
    """
    Settle the assertion, if it has not been disputed and it has passed the challenge window, and return the result.
    result
    """
    return extcall self.oov3.settleAndGetAssertionResult(self.assertionId)

@view
@external
def getAssertionResult() -> bool:
    """
    Just return the assertion result. Can only be called once the assertion has been settled.
    """
    return staticcall self.oov3.getAssertionResult(self.assertionId)

@view
@external
def getAssertion() -> Assertion:
    """
    Return the full assertion object contain all information associated with the assertion. Can be called any time.
    """
    return staticcall self.oov3.getAssertion(self.assertionId)