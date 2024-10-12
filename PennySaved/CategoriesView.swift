//
//  CategoriesView.swift
//  PennySaved
//
//  Created by Victor Saint Hilaire on 8/13/24.
//

import SwiftUI
import CoreData

struct CategoryView: View {
    @State private var categories: [Category] = []
    @Binding var selectedCategory: Category?
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    @State private var showingAddCategory = false
    @State private var showingDeleteAlert = false
    @State private var categoryToDelete: Category?
    @State private var categoryFilter: CategoryFilter = .all
    
    enum CategoryFilter: String, CaseIterable {
        case all = "All"
        case predefined = "Predefined"
        case custom = "Custom"
    }
    
    private var searchFilter: [Category] {
        categories.filter { category in
            let nameMatch = searchText.isEmpty || category.name?.localizedCaseInsensitiveContains(searchText) == true
            switch categoryFilter {
            case .all:
                return nameMatch
            case .predefined:
                return nameMatch && category.isPredefined
            case .custom:
                return nameMatch && !category.isPredefined
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
            VStack {
                SearchBarView(searchingText: $searchText, searchBoxDefaultText: "Category Name")
                    .padding(.horizontal, 15)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        Picker("Filter", selection: $categoryFilter) {
                            ForEach(CategoryFilter.allCases, id: \.self) { filter in
                                Text(filter.rawValue).tag(filter)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(5)
                        .background(Color("boxesBg"))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal, 15)
                }
                
                
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 5),
                                        GridItem(.flexible(), spacing: 5)]) {
                        ForEach(searchFilter, id: \.self) { category in
                            CategoryItemView(
                                category: category,
                                action: {
                                    self.selectedCategory = category
                                    self.presentationMode.wrappedValue.dismiss()
                                },
                                deleteAction: {
                                    if !category.isPredefined {
                                        categoryToDelete = category
                                        showingDeleteAlert = true
                                    }
                                },
                                isSelected: selectedCategory == category
                            )
                        }
                    }
                                        .padding(.horizontal)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("bg"))
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle("Categories")
            .navigationBarItems(trailing: Button("Add") {
                showingAddCategory = true
            })
            .sheet(isPresented: $showingAddCategory) {
                AddCategoryView(categories: $categories)
            }
            .alert(isPresented: $showingDeleteAlert) {
                Alert(
                    title: Text("Delete Category"),
                    message: Text("Are you sure you want to delete this category?"),
                    primaryButton: .destructive(Text("Delete")) {
                        if let category = categoryToDelete {
                            deleteCategory(category)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .onAppear {
            categories = CategoryManager.shared.getLocalCategories()
        }
    }
    
    private func deleteCategory(_ category: Category) {
        CategoryManager.shared.deleteCustomCategory(category)
        categories = CategoryManager.shared.getLocalCategories()
    }
}

struct CategoryItemView: View {
    let category: Category
    let action: () -> Void
    let deleteAction: () -> Void
    let isSelected: Bool
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: category.icon ?? "questionmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(isSelected ? Color("buttonPrimary") : .white)
                
                Text(category.name ?? "Unknown Category")
                    .multilineTextAlignment(.leading)
                    .font(.headline)
                    .foregroundColor(isSelected ? Color("buttonPrimary") : .white)
                
                Spacer()
                
                if !category.isPredefined {
                    Button(action: deleteAction) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                            .opacity(0.7)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color("buttonPrimary"))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .background(isSelected ? Color("boxesBg").opacity(0.3) : Color("boxesBg"))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color("buttonPrimary") : Color.clear, lineWidth: 2)
            )
            .cornerRadius(8)
        }
    }
}

struct AddCategoryView: View {
    @Binding var categories: [Category]
    @State private var name = ""
    @State private var selectedIcon = "questionmark.circle.fill"
    @State private var showingIconPicker = false
    @Environment(\.presentationMode) var presentationMode
    
    let iconOptions = [
        "cart.fill", "fork.knife", "tshirt.fill", "iphone", "bandage.fill",
        "figure.child", "paintbrush.fill", "figure.walk", "car.2.fill",
        "book.closed.fill", "tv.fill", "music.note", "fork.knife.circle.fill",
        "cup.and.saucer.fill", "wineglass.fill", "globe", "hands.sparkles.fill",
        "gift.fill", "pawprint.fill", "hammer.fill", "leaf.fill", "trash.fill",
        "graduationcap.fill", "paperclip", "sportscourt.fill", "puzzlepiece.fill",
        "camera.fill", "cpu.fill", "scissors", "gamecontroller.fill", "diamond.fill",
        "airplane"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    TextField("Category Name", text: $name)
                        .padding()
                        .background(Color("boxesBg"))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                    
                    HStack {
                        Text("Icon")
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: selectedIcon)
                            .foregroundColor(Color("buttonPrimary"))
                        Button("Select Icon") {
                            showingIconPicker = true
                        }
                        .foregroundColor(Color("buttonPrimary"))
                    }
                    .padding()
                    .background(Color("boxesBg"))
                    .cornerRadius(8)
                    
                    Button("Save") {
                        CategoryManager.shared.addCustomCategory(name: name, icon: selectedIcon)
                        categories = CategoryManager.shared.getLocalCategories()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color("buttonPrimary"))
                    .foregroundColor(.black)
                    .cornerRadius(8)
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("bg"))
            .navigationTitle("Add Category")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .sheet(isPresented: $showingIconPicker) {
            IconPickerView(selectedIcon: $selectedIcon)
        }
    }
}

struct IconPickerView: View {
    @Binding var selectedIcon: String
    @Environment(\.presentationMode) var presentationMode
    
    let columns = [
        GridItem(.adaptive(minimum: 50))
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(AddCategoryView(categories: Binding.constant([])).iconOptions, id: \.self) { icon in
                        Image(systemName: icon)
                            .font(.system(size: 30))
                            .frame(width: 50, height: 50)
                            .foregroundColor(selectedIcon == icon ? Color("buttonPrimary") : .white)
                            .background(selectedIcon == icon ? Color("boxesBg").opacity(0.3) : Color("boxesBg"))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(selectedIcon == icon ? Color("buttonPrimary") : Color.clear, lineWidth: 2)
                            )
                            .onTapGesture {
                                selectedIcon = icon
                                presentationMode.wrappedValue.dismiss()
                            }
                    }
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("bg"))
            .navigationTitle("Select Icon")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

//extension Color {
//    init(hex: String) {
//        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
//        var int: UInt64 = 0
//        Scanner(string: hex).scanHexInt64(&int)
//        let a, r, g, b: UInt64
//        switch hex.count {
//        case 3: // RGB (12-bit)
//            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
//        case 6: // RGB (24-bit)
//            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
//        case 8: // ARGB (32-bit)
//            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
//        default:
//            (a, r, g, b) = (255, 0, 0, 0)
//        }
//
//        self.init(
//            .sRGB,
//            red: Double(r) / 255,
//            green: Double(g) / 255,
//            blue: Double(b) / 255,
//            opacity: Double(a) / 255
//        )
//    }
//}



