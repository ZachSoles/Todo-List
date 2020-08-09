//
//  ContentView.swift
//  Todo
//
//  Created by Zach Soles on 7/29/20.
//  Copyright © 2020 Zach Soles. All rights reserved.
//

import SwiftUI


struct ModalView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment (\.presentationMode) var presentationMode
    @State var inputText = ""
    @State var selectedPriority = 1
    let priorityTypes = ["Low","Normal", "High"]
    
    var body: some View {
        NavigationView {
            Form {
                    Section(header: Text("Task Name")) {
                    TextField("Add an item", text: $inputText)
                    }
                    Section(header: Text("Task Details")) {
                        Picker(selection: $selectedPriority, label: Text("Priority Type")) {
                            ForEach(0 ..< priorityTypes.count) {
                                    Text(self.priorityTypes[$0]).tag($0)
                            }
                        }
                    }
                    Button(action:{
                        let student = Student(context: self.moc)
                        student.id = UUID()
                        student.name = self.inputText
                        student.completed = false
                        if(self.selectedPriority == 0){
                            student.priority = "Low"
                        }
                        if(self.selectedPriority == 1){
                            student.priority = "Normal"
                        }
                        if(self.selectedPriority == 2){
                            student.priority = "High"
                        }
                        try? self.moc.save()
                        self.presentationMode.wrappedValue.dismiss()
                        print("Order saved.")
                    }){
                        Text("Save")
                    }
            }
            .navigationBarTitle(Text("Add a task"))
        }
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) var moc
    @State private var show_modal: Bool = false
    @FetchRequest(entity: Student.entity(), sortDescriptors: []) var students: FetchedResults<Student>
    
    private func getColor(priorityLevel: String) -> Color{
        if(priorityLevel == "Normal"){
            return Color.green
        }
        if(priorityLevel == "Normal"){
            return Color.yellow
        }
        if(priorityLevel == "High"){
            return Color.red
        }
        return Color.black
    }
    
    init() {
        // To remove all separators including the actual ones:
        UITableView.appearance().separatorStyle = .none
    }
    
    var body: some View {
        NavigationView{
            VStack{
                List{
                    ForEach(students, id: \.id) { student in
                        HStack{
                            Button(action:{
                                student.completed = !student.completed
                                try? self.moc.save()
                            }){
                                if(student.completed == false){
                                    Image(systemName: "circle").font(Font.system(size: 20))
                                        .foregroundColor(Color.gray)
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color.purple).font(Font.system(size: 20))
                                }
                            }
                            Text(student.name ?? "Unknown")
                            Spacer()
                            Image(systemName: "circle").font(Font.system(size: 15))
                                .foregroundColor(self.getColor(priorityLevel: student.priority ?? "Uknown"))
                        }
                    }
                    .onDelete { Students in
                        for index in Students {
                            self.moc.delete(self.students[index])
                        }
                    }
                }
                HStack{
                    Spacer()
                        .frame(width: 30)
                    Button(action: {
                        self.show_modal = true
                    }){
                        HStack {
                            Image(systemName: "pencil.tip").font(Font.system(size: 20))
                            Text("Add task")
                        }
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.purple)
                        .cornerRadius(.infinity)
                    }
                    .sheet(isPresented: self.$show_modal) {
                        ModalView().environment(\.managedObjectContext, self.moc)
                    }
                    Spacer()
                }
            }
            .navigationBarTitle("Todo App")
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
