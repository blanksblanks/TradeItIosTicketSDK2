import TradeItIosEmsApi

class TradeItLinkedBroker: NSObject {
    var session: TradeItSession
    var linkedLogin: TradeItLinkedLogin
    var accounts: [TradeItAccountPortfolio] = []
    var isAuthenticated = false
//    var error: TradeItErrorResult?

    init(session: TradeItSession, linkedLogin: TradeItLinkedLogin) {
        self.session = session
        self.linkedLogin = linkedLogin
    }

    func authenticate(onSuccess onSuccess: () -> Void,
                      onSecurityQuestion: (TradeItSecurityQuestionResult) -> String,
                      onFailure: (TradeItErrorResult) -> Void) -> Void {
        self.session.authenticate(linkedLogin) { (tradeItResult: TradeItResult!) in
            if let tradeItErrorResult = tradeItResult as? TradeItErrorResult {
                self.isAuthenticated = false
//                self.error = tradeItErrorResult

                onFailure(tradeItErrorResult)
            } else if let tradeItSecurityQuestionResult = tradeItResult as? TradeItSecurityQuestionResult {
                let securityQuestionAnswer = onSecurityQuestion(tradeItSecurityQuestionResult)
                // TODO: submit security question answer
            } else if let tradeItResult = tradeItResult as? TradeItAuthenticationResult {
                self.isAuthenticated = true
//                self.error = nil

                self.accounts = []
                let accounts = tradeItResult.accounts as! [TradeItBrokerAccount]
                for account in accounts {
                    let accountPortfolio = TradeItAccountPortfolio(brokerName: self.linkedLogin.broker,
                                                                   accountName: account.name,
                                                                   accountNumber: account.accountNumber,
                                                                   balance: nil,
                                                                   fxBalance: nil,
                                                                   positions: [])
                    self.accounts.append(accountPortfolio)
                }

                onSuccess()
            }
        }
    }
}