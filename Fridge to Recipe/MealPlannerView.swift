import SwiftUI

struct MealPlannerView: View {
    @EnvironmentObject var appData: AppDataModel
    @EnvironmentObject var shoppingList: ShoppingListViewModel
    @State private var currentDate = Date()

    var body: some View {
        VStack {
            Text("Meal Planner")
                .font(.largeTitle.weight(.bold))
                .padding()

            CalendarGrid(currentDate: $currentDate, mealPlans: $appData.mealPlans) { recipeID, date in
                appData.addRecipe(recipeID, to: date)
                shoppingList.updateSmartList(from: appData.mealPlans, recipes: appData.recipes)
            }
            .padding()

            Text("Recipes")
                .font(.headline)
                .padding(.top)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(appData.recipes) { recipe in
                        Text(recipe.name)
                            .padding(8)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                            .onDrag {
                                NSItemProvider(object: recipe.id.uuidString as NSString)
                            }
                    }
                }
                .padding()
            }
        }
    }
}

struct CalendarGrid: View {
    @Binding var currentDate: Date
    @Binding var mealPlans: [MealPlan]
    var onAdd: (UUID, Date) -> Void

    var body: some View {
        let days = generateDays(for: currentDate)
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
            ForEach(days, id: \\.self) { date in
                DayCell(date: date,
                        recipes: mealPlans.first { Calendar.current.isDate($0.date, inSameDayAs: date) }?.recipeIDs ?? [],
                        onAdd: { id in onAdd(id, date) })
            }
        }
    }

    private func generateDays(for date: Date) -> [Date] {
        let calendar = Calendar.current
        guard let monthRange = calendar.range(of: .day, in: .month, for: date) else { return [] }
        var days: [Date] = []
        let components = calendar.dateComponents([.year, .month], from: date)
        for day in monthRange {
            var dayComponents = components
            dayComponents.day = day
            if let dayDate = calendar.date(from: dayComponents) {
                days.append(dayDate)
            }
        }
        return days
    }
}

struct DayCell: View {
    let date: Date
    let recipes: [UUID]
    var onAdd: (UUID) -> Void
    @EnvironmentObject var appData: AppDataModel

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.subheadline.bold())
            ForEach(recipes, id: \\.self) { id in
                if let recipe = appData.recipes.first(where: { $0.id == id }) {
                    Text(recipe.name)
                        .font(.caption)
                        .lineLimit(1)
                }
            }
        }
        .padding(4)
        .frame(minHeight: 60)
        .background(Color.white.opacity(0.8))
        .cornerRadius(8)
        .onDrop(of: ["public.text"], isTargeted: nil) { providers in
            guard let provider = providers.first else { return false }
            provider.loadObject(ofClass: NSString.self) { item, _ in
                if let str = item as? String, let id = UUID(uuidString: str) {
                    DispatchQueue.main.async {
                        onAdd(id)
                    }
                }
            }
            return true
        }
    }
}

