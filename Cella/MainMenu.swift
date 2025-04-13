import SwiftUI

struct MainMenuView: View {
    // Define the icon data with their destination views
    let iconData: [(name: String, symbol: String, destination: AnyView)] = [
        ("Stock", "archivebox", AnyView(StockView())),
        ("Customers", "person.2", AnyView(CustomersView())),
        ("Staff", "person.crop.circle", AnyView(StaffView())),
        ("Sales Orders", "cart", AnyView(SalesOrderView())),
        ("Scanning", "qrcode.viewfinder", AnyView(ScanningView())),
        ("Pick List", "list.bullet.clipboard", AnyView(PickListView())),
        ("Weigh Bridge", "scalemass", AnyView(WeightBridgeView()))
    ]
    
    // Define a 2-column grid layout
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 24) {
                ForEach(iconData, id: \.name) { item in
                    NavigationLink(destination: item.destination) {
                        VStack {
                            Image(systemName: item.symbol)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 64, height: 64)
                                .padding()
                                .shadow(radius: 5)  // Adds a subtle shadow around the icon

                            Text(item.name)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("") // No title on the Dashboard page
        }
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
    }
}
