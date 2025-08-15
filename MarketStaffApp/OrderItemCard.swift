import SwiftUI

struct OrderItemCard: View {
    let item: OrderItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if let urlString = item.imageUrl,
               let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image.resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: 60, height: 60)
                .cornerRadius(8)
                .clipped()
            } else {
                Color.gray.opacity(0.2)
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.subheadline)
                    .bold()

                Text("Quantity: \(item.quantity)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(String(format: "$%.2f each", item.price))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(String(format: "$%.2f", item.price * Double(item.quantity)))
                .bold()
                .frame(minWidth: 60, alignment: .trailing)
        }
        .padding()
        .frame(height: 100)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 1)
    }
}
