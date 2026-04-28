//
//  StockListView.swift
//  StockTracker
//
//  Created by Samuel Yanez on 4/27/26.
//

import SwiftUI

struct StockListView: View {
    @State private var viewModel = StockListViewModel()

    var body: some View {
        NavigationStack {
            List(viewModel.stocks) { stock in
                StockRowView(stock: stock, quote: viewModel.quote(for: stock))
            }
            .navigationTitle("Stocks")
            .errorAlert(
                isPresented: $viewModel.isShowingErrorAlert,
                message: viewModel.errorMessage,
                dismiss: viewModel.dismissError
            )
            .onChange(of: viewModel.errorMessage) { _, errorMessage in
                if errorMessage != nil {
                    viewModel.isShowingErrorAlert = true
                }
            }
            .task {
                await viewModel.startPolling()
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
    }
}

private extension View {
    func errorAlert(
        isPresented: Binding<Bool>,
        message: String?,
        dismiss: @escaping () -> Void
    ) -> some View {
        alert(
            "Error",
            isPresented: isPresented,
            actions: {
                Button("Dismiss") {
                    dismiss()
                }
            },
            message: {
                Text(message ?? "Please try again later.")
            }
        )
    }
}

#Preview {
    StockListView()
}
