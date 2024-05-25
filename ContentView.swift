import SwiftUI

// Currency enum to support Riels and Dollars
enum Currency: String, CaseIterable, Identifiable {
    case riels = "KHR"
    case dollars = "USD"
    
    var id: String { self.rawValue }
}

// Transaction struct to store individual transactions with descriptions
struct Transaction: Identifiable {
    let id = UUID()
    let amount: Double
    let currency: Currency
    let type: TransactionType
    let description: String
}

// Enum for Transaction Types
enum TransactionType: String {
    case income = "Income"
    case expense = "Expense"
}

// Budget class to handle income, expenses, and balance
class Budget: ObservableObject {
    @Published var balanceInRiels: Double = 0.0
    @Published var balanceInDollars: Double = 0.0
    @Published var transactions: [Transaction] = []
    
    func addTransaction(amount: Double, currency: Currency, type: TransactionType, description: String) {
        let transaction = Transaction(amount: amount, currency: currency, type: type, description: description)
        transactions.insert(transaction, at: 0)
        
        switch (type, currency) {
        case (.income, .riels):
            balanceInRiels += amount
        case (.income, .dollars):
            balanceInDollars += amount
        case (.expense, .riels):
            balanceInRiels -= amount
        case (.expense, .dollars):
            balanceInDollars -= amount
        }
    }
    
    func getBalance(currency: Currency) -> Double {
        switch currency {
        case .riels:
            return balanceInRiels
        case .dollars:
            return balanceInDollars
        }
    }
}

// SwiftUI ContentView
struct ContentView: View {
    @State private var amount: String = ""
    @State private var currency: Currency = .dollars
    @State private var description: String = ""
    @ObservedObject var budget = Budget()
    @State private var isHistoryVisible = false
    
    var body: some View {
        NavigationView {
            VStack {
                VStack(spacing: 10) {
                    Text("Current Balance")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(spacing: 5) {
                        Text("\(budget.getBalance(currency: .dollars), specifier: "%.2f") USD")
                            .font(.system(size: 48, weight: .bold, design: .default))
                            .foregroundColor(.green)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        
                        Text("\(budget.getBalance(currency: .riels), specifier: "%.2f") KHR")
                            .font(.system(size: 48, weight: .bold, design: .default))
                            .foregroundColor(.green)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal)
                
                Spacer()
                
                VStack(spacing: 20) {
                    VStack {
                        Text("Amount")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.bottom, 5)
                        
                        TextField("Amount", text: $amount)
                            .keyboardType(.decimalPad)
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    
                    VStack {
                        Text("Description")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.bottom, 5)
                        
                        TextField("Description", text: $description)
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    
                    Picker("Currency", selection: $currency) {
                        ForEach(Currency.allCases) { currency in
                            Text(currency.rawValue).tag(currency)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    HStack(spacing: 40) {
                        Button(action: {
                            if let amount = Double(self.amount) {
                                self.budget.addTransaction(amount: amount, currency: self.currency, type: .income, description: self.description)
                                self.amount = ""
                                self.description = ""
                            }
                        }) {
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .font(.system(size: 24, weight: .bold))
                                .frame(width: 60, height: 60)
                                .background(Color.blue)
                                .clipShape(Circle())
                        }
                        
                        Button(action: {
                            if let amount = Double(self.amount) {
                                self.budget.addTransaction(amount: amount, currency: self.currency, type: .expense, description: self.description)
                                self.amount = ""
                                self.description = ""
                            }
                        }) {
                            Image(systemName: "minus")
                                .foregroundColor(.white)
                                .font(.system(size: 24, weight: .bold))
                                .frame(width: 60, height: 60)
                                .background(Color.red)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 40)
            }
            .background(Color.white.edgesIgnoringSafeArea(.all))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        self.isHistoryVisible.toggle()
                    }) {
                        Image(systemName: "clock")
                    }
                }
            }
            .sheet(isPresented: $isHistoryVisible) {
                HistoryView(budget: self.budget)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Ensures proper rendering on iPad and iPhone
    }
}

struct HistoryView: View {
    @ObservedObject var budget: Budget
    
    var body: some View {
        NavigationView {
            List(budget.transactions) { transaction in
                VStack(alignment: .leading) {
                    Text("\(transaction.amount, specifier: "%.2f") \(transaction.currency.rawValue)")
                        .font(.headline)
                        .foregroundColor(transaction.type == .income ? .green : .red)
                    Text(transaction.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text(transaction.type.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Transactions")
        }
    }
}
