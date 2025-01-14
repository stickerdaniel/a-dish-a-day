//
//  File.swift
//  calendar
//
//  Created by Lucy May Plassmann on 12.01.25.
//

import SwiftUI

struct AddRecipeView: View{
    @State private var name = ""
    @State private var ingredients = ""
    @State private var description = ""
    @State public var textHeightIng: CGFloat = 40 // Default height
    @State public var textHeightDes: CGFloat = 40 // Default height
    
    @Environment(\.modelContext) private var context

    var body: some View {
        NavigationStack {
            Form {
                Section() {
                    ZStack(alignment: .leading) {
                        TextField("", text: $name)
                        if name.isEmpty {
                            Text("Name")
                                .foregroundColor(.gray)
                                .padding(.leading, 10) // Align with TextField input
                        }
                            }
                }
                Section() {
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $ingredients)
                            .frame(height: textHeightIng)
                            .padding(8)
                            //.background(Color(UIColor.systemGray6))
                            .cornerRadius(10)
                            .onChange(of: ingredients) { _ in
                                updateHeight(text: ingredients, textHeight: "Ingredients")
                            }
                        if ingredients.isEmpty {
                           Text("Ingredients")
                               .foregroundColor(.gray)
                               .padding(.leading, 14)
                               .padding(.top, 10) // Aligns properly inside TextEditor
                       }
                        
                        Spacer()
                    }
                }
                Section() {
                    ZStack(alignment: .topLeading) {
                       
                        TextEditor(text: $description)
                            .frame(height: textHeightDes)
                            .padding(8)
                            .cornerRadius(10)
                            .onChange(of: description) { _ in
                                updateHeight(text: description, textHeight: "Description")
                            }
                        if description.isEmpty {
                            Text("Description")
                                .foregroundColor(.gray)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                        }
                        
                        
                        Spacer()
                    }
                }
                Button("Add Recipe") {
                    context.insert(Recipe(name: name, text: description, ingredients: ingredients))
                }
                .disabled(name.isEmpty)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.bottom, 10)


            }
        }

            }
            /// Function to calculate dynamic height
    private func updateHeight(text: String, textHeight: String) {
            let textSize = text.heightWithConstrainedWidth(width: UIScreen.main.bounds.width - 40, font: .systemFont(ofSize: 17))
                if textHeight == "Description" {
                    textHeightDes = max(40, textSize + 20)
                } else {
                    textHeightIng =  max(40, textSize + 20)
                }
                // Ensures it doesn’t shrink too much
            }
        }

        // Extension to measure text height dynamically
        extension String {
            func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
                let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
                let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
                return ceil(boundingBox.height)
            }
        }



