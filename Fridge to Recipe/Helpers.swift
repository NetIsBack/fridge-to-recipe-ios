// Helpers.swift
import SwiftUI
import Foundation
import Combine

import UserNotifications
import UIKit

let sampleRecipes: [Recipe] = [
    Recipe(
        id: UUID(),
        name: "Classic Scrambled Eggs",
        ingredients: ["eggs", "milk", "butter", "salt", "pepper"],
        dietaryTags: ["vegetarian"],
        cookingTime: "5 minutes",
        instructions: [
            "Whisk eggs, milk, salt, and pepper in a small bowl.",
            "Melt butter in a non-stick skillet over medium heat.",
            "Pour in the egg mixture and cook, stirring gently, until the eggs are lightly set.",
            "Remove from heat and serve immediately."
        ],
        ingredientAmounts: ["eggs": "2", "milk": "2 tbsp", "butter": "1 tsp", "salt": "pinch", "pepper": "pinch"],
        isAIGenerated: false,
        difficulty: "Easy",
        steps: [
            RecipeStep(name: "Whisk eggs, milk, salt, and pepper", duration: 60),
            RecipeStep(name: "Melt butter in skillet", duration: 60),
            RecipeStep(name: "Cook eggs, stirring gently", duration: 120),
            RecipeStep(name: "Remove from heat and serve", duration: 30)
        ]
    ),
    Recipe(
        id: UUID(),
        name: "Chocolate Chip Cookies",
        ingredients: ["flour", "butter", "sugar", "egg", "chocolate chips", "vanilla", "baking soda", "salt"],
        dietaryTags: ["vegetarian"],
        cookingTime: "25 minutes",
        instructions: [
            "Cream butter and sugar, add eggs and vanilla.",
            "Mix in flour, baking soda, salt, and chocolate chips.",
            "Drop spoonfuls onto baking sheet, bake at 375°F for 10-12 minutes."
        ],
        ingredientAmounts: ["flour": "2 1/4 cups", "butter": "1 cup", "sugar": "3/4 cup", "egg": "2", "chocolate chips": "2 cups", "vanilla": "1 tsp", "baking soda": "1 tsp", "salt": "1/2 tsp"],
        isAIGenerated: false,
        difficulty: "Easy",
        steps: [
            RecipeStep(name: "Cream butter and sugar", duration: 120),
            RecipeStep(name: "Add eggs and vanilla", duration: 60),
            RecipeStep(name: "Mix in flour, baking soda, salt, and chocolate chips", duration: 120),
            RecipeStep(name: "Drop spoonfuls onto baking sheet", duration: 180),
            RecipeStep(name: "Bake at 375°F for 10-12 minutes", duration: 720)
        ]
    ),
    Recipe(
        id: UUID(),
        name: "Chicken Stir Fry",
        ingredients: ["chicken breast", "broccoli", "carrot", "soy sauce", "garlic", "ginger", "vegetable oil", "rice"],
        dietaryTags: [],
        cookingTime: "20 minutes",
        instructions: [
            "Cook rice according to package directions.",
            "Stir-fry chicken until golden, add vegetables.",
            "Add soy sauce, garlic, and ginger, cook until vegetables are tender."
        ],
        ingredientAmounts: ["chicken breast": "1 lb", "broccoli": "2 cups", "carrot": "2", "soy sauce": "3 tbsp", "garlic": "3 cloves", "ginger": "1 tbsp", "vegetable oil": "2 tbsp", "rice": "2 cups"],
        isAIGenerated: false,
        difficulty: "Medium",
        steps: [
            RecipeStep(name: "Cook rice according to package directions", duration: 600),
            RecipeStep(name: "Stir-fry chicken until golden", duration: 300),
            RecipeStep(name: "Add vegetables", duration: 120),
            RecipeStep(name: "Add soy sauce, garlic, and ginger", duration: 180),
            RecipeStep(name: "Cook until vegetables are tender", duration: 120)
        ]
    ),
    Recipe(
        id: UUID(),
        name: "Pasta Carbonara",
        ingredients: ["spaghetti", "bacon", "egg", "parmesan cheese", "garlic", "black pepper", "salt"],
        dietaryTags: [],
        cookingTime: "20 minutes",
        instructions: [
            "Cook pasta in salted water.",
            "Cook bacon until crispy, add garlic.",
            "Toss pasta with eggs, cheese, and bacon mixture."
        ],
        ingredientAmounts: ["spaghetti": "1 lb", "bacon": "8 oz", "egg": "4", "parmesan cheese": "1 cup", "garlic": "4 cloves", "black pepper": "to taste", "salt": "to taste"],
        isAIGenerated: false,
        difficulty: "Medium",
        steps: [
            RecipeStep(name: "Cook pasta in salted water", duration: 600),
            RecipeStep(name: "Cook bacon until crispy", duration: 300),
            RecipeStep(name: "Add garlic to bacon", duration: 60),
            RecipeStep(name: "Toss pasta with eggs, cheese, and bacon mixture", duration: 120)
        ]
    ),
    Recipe(
        id: UUID(),
        name: "Greek Salad",
        ingredients: ["cucumber", "tomato", "red onion", "feta cheese", "olive", "olive oil", "lemon", "oregano"],
        dietaryTags: ["vegetarian", "gluten-free"],
        cookingTime: "10 minutes",
        instructions: [
            "Chop cucumber, tomato, and red onion.",
            "Mix with crumbled feta, olives, olive oil, lemon juice, and oregano."
        ],
        ingredientAmounts: ["cucumber": "1", "tomato": "2", "red onion": "1/2", "feta cheese": "1 cup", "olive": "1/2 cup", "olive oil": "3 tbsp", "lemon": "1", "oregano": "1 tsp"],
        isAIGenerated: false,
        difficulty: "Easy",
        steps: [
            RecipeStep(name: "Chop cucumber, tomato, and red onion", duration: 300),
            RecipeStep(name: "Mix with crumbled feta, olives, olive oil, lemon juice, and oregano", duration: 300)
        ]
    ),
    Recipe(
        id: UUID(),
        name: "Beef Tacos",
        ingredients: ["ground beef", "taco seasoning", "tortilla", "lettuce", "tomato", "cheese", "sour cream", "onion"],
        dietaryTags: [],
        cookingTime: "15 minutes",
        instructions: [
            "Cook ground beef with taco seasoning.",
            "Warm tortillas, assemble with beef, lettuce, tomato, cheese, sour cream, and onion."
        ],
        ingredientAmounts: ["ground beef": "1 lb", "taco seasoning": "1 packet", "tortilla": "8", "lettuce": "2 cups", "tomato": "2", "cheese": "1 cup", "sour cream": "1/2 cup", "onion": "1"],
        isAIGenerated: false,
        difficulty: "Easy",
        steps: [
            RecipeStep(name: "Cook ground beef with taco seasoning", duration: 300),
            RecipeStep(name: "Warm tortillas", duration: 120),
            RecipeStep(name: "Assemble with beef, lettuce, tomato, cheese, sour cream, and onion", duration: 180)
        ]
    ),
    Recipe(
        id: UUID(),
        name: "Shrimp Scampi",
        ingredients: ["shrimp", "spaghetti", "garlic", "butter", "lemon", "parsley", "olive oil"],
        dietaryTags: [],
        cookingTime: "20 minutes",
        instructions: [
            "Cook spaghetti. Sauté garlic in butter and oil, add shrimp, cook until pink.",
            "Add lemon juice and parsley, toss with pasta."
        ],
        ingredientAmounts: ["shrimp": "1 lb", "spaghetti": "8 oz", "garlic": "3 cloves", "butter": "2 tbsp", "lemon": "1", "parsley": "2 tbsp", "olive oil": "2 tbsp"],
        isAIGenerated: false,
        difficulty: "Medium",
        steps: [
            RecipeStep(name: "Cook spaghetti", duration: 300),
            RecipeStep(name: "Sauté garlic in butter and oil", duration: 300),
            RecipeStep(name: "Add shrimp, cook until pink", duration: 300),
            RecipeStep(name: "Add lemon juice and parsley", duration: 60),
            RecipeStep(name: "Toss with pasta", duration: 30)
        ]
    ),
    Recipe(
        id: UUID(),
        name: "Quinoa Salad",
        ingredients: ["quinoa", "cucumber", "tomato", "feta cheese", "olive oil", "lemon", "parsley"],
        dietaryTags: ["vegetarian", "gluten-free"],
        cookingTime: "25 minutes",
        instructions: [
            "Cook quinoa and let cool.",
            "Chop vegetables, mix with quinoa, feta, olive oil, lemon, and parsley."
        ],
        ingredientAmounts: ["quinoa": "1 cup", "cucumber": "1", "tomato": "2", "feta cheese": "1/2 cup", "olive oil": "2 tbsp", "lemon": "1", "parsley": "2 tbsp"],
        isAIGenerated: false,
        difficulty: "Easy",
        steps: [
            RecipeStep(name: "Cook quinoa", duration: 900),
            RecipeStep(name: "Chop vegetables", duration: 300),
            RecipeStep(name: "Mix quinoa, vegetables, feta, olive oil, lemon, parsley", duration: 60)
        ]
    ),
    Recipe(
        id: UUID(),
        name: "Pancakes",
        ingredients: ["flour", "milk", "egg", "butter", "sugar", "baking powder", "salt", "vanilla"],
        dietaryTags: ["vegetarian"],
        cookingTime: "15 minutes",
        instructions: [
            "Mix flour, sugar, baking powder, and salt.",
            "Whisk in milk, eggs, melted butter, and vanilla.",
            "Cook on griddle until bubbles form, flip and cook other side."
        ],
        ingredientAmounts: ["flour": "1 1/2 cups", "milk": "1 1/4 cups", "egg": "2", "butter": "3 tbsp", "sugar": "2 tbsp", "baking powder": "2 tsp", "salt": "1/2 tsp", "vanilla": "1 tsp"],
        isAIGenerated: false,
        difficulty: "Easy",
        steps: [
            RecipeStep(name: "Mix flour, sugar, baking powder, and salt", duration: 120),
            RecipeStep(name: "Whisk in milk, eggs, melted butter, and vanilla", duration: 120),
            RecipeStep(name: "Cook on griddle until bubbles form", duration: 180),
            RecipeStep(name: "Flip and cook other side", duration: 120)
        ]
    ),
    Recipe(
        id: UUID(),
        name: "Chicken Noodle Soup",
        ingredients: ["chicken breast", "carrot", "celery", "onion", "egg noodles", "chicken broth", "garlic", "parsley"],
        dietaryTags: [],
        cookingTime: "45 minutes",
        instructions: [
            "Sauté onion, carrot, and celery in oil.",
            "Add broth, chicken, and noodles, simmer until chicken is cooked and noodles are tender."
        ],
        ingredientAmounts: ["chicken breast": "1 lb", "carrot": "3", "celery": "3 stalks", "onion": "1", "egg noodles": "8 oz", "chicken broth": "8 cups", "garlic": "3 cloves", "parsley": "2 tbsp"],
        isAIGenerated: false,
        difficulty: "Easy",
        steps: [
            RecipeStep(name: "Sauté onion, carrot, and celery in oil", duration: 300),
            RecipeStep(name: "Add broth and chicken", duration: 120),
            RecipeStep(name: "Simmer until chicken is cooked", duration: 1200),
            RecipeStep(name: "Add noodles and cook until tender", duration: 600),
            RecipeStep(name: "Garnish with parsley", duration: 30)
        ]
    ),
    Recipe(
        id: UUID(),
        name: "Mushroom Risotto",
        ingredients: ["arborio rice", "mushroom", "onion", "garlic", "parmesan cheese", "vegetable broth", "butter", "white wine"],
        dietaryTags: ["vegetarian"],
        cookingTime: "40 minutes",
        instructions: [
            "Sauté onion, garlic, and mushrooms in butter.",
            "Add rice, wine, then broth gradually, stirring until creamy. Finish with parmesan."
        ],
        ingredientAmounts: ["arborio rice": "1 cup", "mushroom": "2 cups", "onion": "1", "garlic": "2 cloves", "parmesan cheese": "1/2 cup", "vegetable broth": "4 cups", "butter": "2 tbsp", "white wine": "1/2 cup"],
        isAIGenerated: false,
        difficulty: "Medium",
        steps: [
            RecipeStep(name: "Sauté onion, garlic, and mushrooms in butter", duration: 300),
            RecipeStep(name: "Add rice, wine, then broth gradually", duration: 300),
            RecipeStep(name: "Stir until creamy, finish with parmesan", duration: 300)
        ]
    ),
    Recipe(
        id: UUID(),
        name: "Fish Tacos",
        ingredients: ["white fish", "tortillas", "cabbage", "lime", "cilantro", "sour cream", "avocado", "hot sauce"],
        dietaryTags: [],
        cookingTime: "25 minutes",
        instructions: [
            "Cook fish with spices, warm tortillas.",
            "Assemble with cabbage, avocado, sour cream, cilantro, and lime."
        ],
        ingredientAmounts: ["white fish": "1 lb", "tortillas": "8", "cabbage": "1 cup", "lime": "1", "cilantro": "2 tbsp", "sour cream": "1/4 cup", "avocado": "1", "hot sauce": "to taste"],
        isAIGenerated: false,
        difficulty: "Easy",
        steps: [
            RecipeStep(name: "Cook fish with spices", duration: 300),
            RecipeStep(name: "Warm tortillas", duration: 120),
            RecipeStep(name: "Assemble with cabbage, avocado, sour cream, cilantro, lime", duration: 60)
        ]
    ),
    Recipe(
        id: UUID(),
        name: "Caesar Salad",
        ingredients: ["romaine lettuce", "parmesan cheese", "croutons", "lemon", "garlic", "olive oil", "anchovy", "black pepper"],
        dietaryTags: ["vegetarian"],
        cookingTime: "10 minutes",
        instructions: [
            "Chop romaine lettuce.",
            "Make dressing with lemon, garlic, olive oil, anchovy, and black pepper.",
            "Toss lettuce with dressing, top with parmesan and croutons."
        ],
        ingredientAmounts: ["romaine lettuce": "2 heads", "parmesan cheese": "1/2 cup", "croutons": "1 cup", "lemon": "1", "garlic": "2 cloves", "olive oil": "1/4 cup", "anchovy": "2 fillets", "black pepper": "to taste"],
        isAIGenerated: false,
        difficulty: "Easy",
        steps: [
            RecipeStep(name: "Chop romaine lettuce", duration: 120),
            RecipeStep(name: "Make dressing with lemon, garlic, olive oil, anchovy, and black pepper", duration: 180),
            RecipeStep(name: "Toss lettuce with dressing", duration: 60),
            RecipeStep(name: "Top with parmesan and croutons", duration: 30)
        ]
    ),
    Recipe(
        id: UUID(),
        name: "Beef Stroganoff",
        ingredients: ["beef sirloin", "mushroom", "onion", "sour cream", "beef broth", "egg noodles", "butter", "flour"],
        dietaryTags: [],
        cookingTime: "40 minutes",
        instructions: [
            "Sauté beef, onion, and mushrooms in butter.",
            "Add flour, broth, simmer. Stir in sour cream, serve over noodles."
        ],
        ingredientAmounts: ["beef sirloin": "1 lb", "mushroom": "2 cups", "onion": "1", "sour cream": "1 cup", "beef broth": "2 cups", "egg noodles": "8 oz", "butter": "2 tbsp", "flour": "2 tbsp"],
        isAIGenerated: false,
        difficulty: "Medium",
        steps: [
            RecipeStep(name: "Sauté beef, onion, and mushrooms in butter", duration: 300),
            RecipeStep(name: "Add flour, broth, simmer", duration: 300),
            RecipeStep(name: "Stir in sour cream, serve over noodles", duration: 60)
        ]
    ),
    Recipe(
        id: UUID(),
        name: "Vegetable Quesadilla",
        ingredients: ["flour tortilla", "cheddar cheese", "bell pepper", "onion", "mushroom", "olive oil", "salsa"],
        dietaryTags: ["vegetarian"],
        cookingTime: "15 minutes",
        instructions: [
            "Sauté vegetables, layer on tortilla with cheese.",
            "Cook on skillet until golden, serve with salsa."
        ],
        ingredientAmounts: ["flour tortilla": "2", "cheddar cheese": "1 cup", "bell pepper": "1", "onion": "1/2", "mushroom": "1 cup", "olive oil": "1 tbsp", "salsa": "1/2 cup"],
        isAIGenerated: false,
        difficulty: "Easy",
        steps: [
            RecipeStep(name: "Sauté vegetables", duration: 300),
            RecipeStep(name: "Layer on tortilla with cheese", duration: 60),
            RecipeStep(name: "Cook on skillet until golden, serve with salsa", duration: 60)
        ]
    ),
    Recipe(
        id: UUID(),
        name: "Lemon Garlic Shrimp",
        ingredients: ["shrimp", "lemon", "garlic", "butter", "parsley", "white wine", "salt", "pepper"],
        dietaryTags: [],
        cookingTime: "15 minutes",
        instructions: [
            "Sauté garlic in butter, add shrimp.",
            "Add lemon juice, white wine, parsley, salt, and pepper. Cook until shrimp are pink."
        ],
        ingredientAmounts: ["shrimp": "1 lb", "lemon": "1", "garlic": "4 cloves", "butter": "3 tbsp", "parsley": "2 tbsp", "white wine": "1/4 cup", "salt": "to taste", "pepper": "to taste"],
        isAIGenerated: false,
        difficulty: "Easy",
        steps: [
            RecipeStep(name: "Sauté garlic in butter", duration: 120),
            RecipeStep(name: "Add shrimp", duration: 60),
            RecipeStep(name: "Add lemon juice, white wine, parsley, salt, and pepper", duration: 120),
            RecipeStep(name: "Cook until shrimp are pink", duration: 180)
        ]
    ),
    Recipe(
        id: UUID(),
        name: "Asian Chicken Salad",
        ingredients: ["chicken breast", "lettuce", "mandarin orange", "almond", "green onion", "soy sauce", "sesame oil", "ginger"],
        dietaryTags: [],
        cookingTime: "25 minutes",
        instructions: [
            "Grill chicken, slice.",
            "Toss lettuce with orange, almond, onion, and dressing. Top with chicken."
        ],
        ingredientAmounts: ["chicken breast": "1", "lettuce": "4 cups", "mandarin orange": "1/2 cup", "almond": "1/4 cup", "green onion": "2", "soy sauce": "2 tbsp", "sesame oil": "1 tbsp", "ginger": "1 tsp"],
        isAIGenerated: false,
        difficulty: "Easy",
        steps: [
            RecipeStep(name: "Grill chicken, slice", duration: 300),
            RecipeStep(name: "Toss lettuce with orange, almond, onion, and dressing", duration: 60),
            RecipeStep(name: "Top with chicken", duration: 60)
        ]
    ),
    Recipe(
        id: UUID(),
        name: "Classic Meatloaf",
        ingredients: ["ground beef", "egg", "onion", "breadcrumbs", "ketchup", "milk", "salt", "pepper"],
        dietaryTags: [],
        cookingTime: "1 hour",
        instructions: [
            "Mix all ingredients, shape into loaf.",
            "Bake at 350°F for 50-60 minutes."
        ],
        ingredientAmounts: ["ground beef": "1 lb", "egg": "1", "onion": "1", "breadcrumbs": "1 cup", "ketchup": "1/2 cup", "milk": "1/2 cup", "salt": "to taste", "pepper": "to taste"],
        isAIGenerated: false,
        difficulty: "Medium",
        steps: [
            RecipeStep(name: "Mix all ingredients, shape into loaf", duration: 60),
            RecipeStep(name: "Bake at 350°F for 50-60 minutes", duration: 3600)
        ]
    ),
    Recipe(
        id: UUID(),
        name: "Spaghetti Bolognese",
        ingredients: ["spaghetti", "ground beef", "tomato", "onion", "garlic", "basil", "parmesan cheese", "olive oil"],
        dietaryTags: [],
        cookingTime: "45 minutes",
        instructions: [
            "Sauté onion and garlic, add ground beef and brown.",
            "Add tomatoes and basil, simmer. Cook spaghetti, serve with sauce and parmesan."
        ],
        ingredientAmounts: ["spaghetti": "1 lb", "ground beef": "1 lb", "tomato": "4", "onion": "1", "garlic": "4 cloves", "basil": "1/4 cup", "parmesan cheese": "1 cup", "olive oil": "2 tbsp"],
        isAIGenerated: false,
        difficulty: "Medium",
        steps: [
            RecipeStep(name: "Sauté onion and garlic", duration: 180),
            RecipeStep(name: "Add ground beef and brown", duration: 300),
            RecipeStep(name: "Add tomatoes and basil, simmer", duration: 1200),
            RecipeStep(name: "Cook spaghetti", duration: 600),
            RecipeStep(name: "Serve with sauce and parmesan", duration: 60)
        ]
    ),
    Recipe(
        id: UUID(),
        name: "Chicken Curry",
        ingredients: ["chicken breast", "coconut milk", "curry powder", "onion", "garlic", "ginger", "rice", "cilantro"],
        dietaryTags: [],
        cookingTime: "35 minutes",
        instructions: [
            "Sauté onion, garlic, and ginger, add chicken and curry powder.",
            "Add coconut milk, simmer until chicken is cooked. Serve over rice with cilantro."
        ],
        ingredientAmounts: ["chicken breast": "1 lb", "coconut milk": "1 can", "curry powder": "2 tbsp", "onion": "1", "garlic": "4 cloves", "ginger": "1 tbsp", "rice": "2 cups", "cilantro": "1/4 cup"],
        isAIGenerated: false,
        difficulty: "Medium",
        steps: [
            RecipeStep(name: "Sauté onion, garlic, and ginger", duration: 180),
            RecipeStep(name: "Add chicken and curry powder", duration: 120),
            RecipeStep(name: "Add coconut milk, simmer until chicken is cooked", duration: 1200),
            RecipeStep(name: "Serve over rice with cilantro", duration: 60)
        ]
    ),
    Recipe(
        id: UUID(),
        name: "Greek Yogurt Parfait",
        ingredients: ["greek yogurt", "honey", "granola", "strawberry", "blueberry", "mint"],
        dietaryTags: ["vegetarian", "gluten-free"],
        cookingTime: "5 minutes",
        instructions: [
            "Layer greek yogurt, honey, granola, and berries in a glass.",
            "Top with fresh mint leaves."
        ],
        ingredientAmounts: ["greek yogurt": "2 cups", "honey": "2 tbsp", "granola": "1 cup", "strawberry": "1 cup", "blueberry": "1 cup", "mint": "4 leaves"],
        isAIGenerated: false,
        difficulty: "Easy",
        steps: [
            RecipeStep(name: "Layer greek yogurt, honey, granola, and berries in a glass", duration: 180),
            RecipeStep(name: "Top with fresh mint leaves", duration: 30)
        ]
    ),
    Recipe(
        id: UUID(),
        name: "Grilled Cheese Sandwich",
        ingredients: ["bread", "cheddar cheese", "butter", "tomato soup"],
        dietaryTags: ["vegetarian"],
        cookingTime: "10 minutes",
        instructions: [
            "Butter bread slices, add cheese between slices.",
            "Grill on skillet until golden and cheese melts. Serve with tomato soup."
        ],
        ingredientAmounts: ["bread": "4 slices", "cheddar cheese": "4 slices", "butter": "2 tbsp", "tomato soup": "2 cups"],
        isAIGenerated: false,
        difficulty: "Easy",
        steps: [
            RecipeStep(name: "Butter bread slices, add cheese between slices", duration: 120),
            RecipeStep(name: "Grill on skillet until golden and cheese melts", duration: 300),
            RecipeStep(name: "Serve with tomato soup", duration: 60)
        ]
    ),
    Recipe(
        id: UUID(),
        name: "Avocado Toast",
        ingredients: ["bread", "avocado", "egg", "salt", "pepper", "red pepper flakes", "lemon"],
        dietaryTags: ["vegetarian"],
        cookingTime: "8 minutes",
        instructions: [
            "Toast bread, mash avocado with lemon, salt, and pepper.",
            "Spread on toast, top with fried egg and red pepper flakes."
        ],
        ingredientAmounts: ["bread": "2 slices", "avocado": "1", "egg": "2", "salt": "to taste", "pepper": "to taste", "red pepper flakes": "to taste", "lemon": "1/2"],
        isAIGenerated: false,
        difficulty: "Easy",
        steps: [
            RecipeStep(name: "Toast bread", duration: 120),
            RecipeStep(name: "Mash avocado with lemon, salt, and pepper", duration: 120),
            RecipeStep(name: "Spread on toast", duration: 60),
            RecipeStep(name: "Top with fried egg and red pepper flakes", duration: 180)
        ]
    ),
    Recipe(
        id: UUID(),
        name: "Smoothie Bowl",
        ingredients: ["banana", "strawberry", "greek yogurt", "honey", "granola", "coconut", "mint"],
        dietaryTags: ["vegetarian", "gluten-free"],
        cookingTime: "5 minutes",
        instructions: [
            "Blend banana, strawberries, greek yogurt, and honey.",
            "Pour into bowl, top with granola, coconut, and mint."
        ],
        ingredientAmounts: ["banana": "2", "strawberry": "1 cup", "greek yogurt": "1 cup", "honey": "2 tbsp", "granola": "1/2 cup", "coconut": "2 tbsp", "mint": "4 leaves"],
        isAIGenerated: false,
        difficulty: "Easy",
        steps: [
            RecipeStep(name: "Blend banana, strawberries, greek yogurt, and honey", duration: 120),
            RecipeStep(name: "Pour into bowl", duration: 30),
            RecipeStep(name: "Top with granola, coconut, and mint", duration: 90)
        ]
    ),
    Recipe(
        id: UUID(),
        name: "Chicken Fajitas",
        ingredients: ["chicken breast", "bell pepper", "onion", "tortilla", "lime", "cilantro", "sour cream", "cheese"],
        dietaryTags: [],
        cookingTime: "25 minutes",
        instructions: [
            "Sauté chicken with fajita seasoning, add peppers and onions.",
            "Warm tortillas, serve with lime, cilantro, sour cream, and cheese."
        ],
        ingredientAmounts: ["chicken breast": "1 lb", "bell pepper": "3", "onion": "1", "tortilla": "8", "lime": "2", "cilantro": "1/4 cup", "sour cream": "1/2 cup", "cheese": "1 cup"],
        isAIGenerated: false,
        difficulty: "Easy",
        steps: [
            RecipeStep(name: "Sauté chicken with fajita seasoning", duration: 300),
            RecipeStep(name: "Add peppers and onions", duration: 300),
            RecipeStep(name: "Warm tortillas", duration: 120),
            RecipeStep(name: "Serve with lime, cilantro, sour cream, and cheese", duration: 60)
        ]
    ),
    Recipe(
        id: UUID(),
        name: "Pasta Primavera",
        ingredients: ["spaghetti", "broccoli", "carrot", "bell pepper", "zucchini", "garlic", "olive oil", "parmesan cheese"],
        dietaryTags: ["vegetarian"],
        cookingTime: "20 minutes",
        instructions: [
            "Cook pasta, sauté vegetables in olive oil with garlic.",
            "Toss pasta with vegetables and parmesan cheese."
        ],
        ingredientAmounts: ["spaghetti": "1 lb", "broccoli": "2 cups", "carrot": "2", "bell pepper": "1", "zucchini": "2", "garlic": "4 cloves", "olive oil": "3 tbsp", "parmesan cheese": "1 cup"],
        isAIGenerated: false,
        difficulty: "Easy",
        steps: [
            RecipeStep(name: "Cook pasta", duration: 600),
            RecipeStep(name: "Sauté vegetables in olive oil with garlic", duration: 300),
            RecipeStep(name: "Toss pasta with vegetables and parmesan cheese", duration: 120)
        ]
    ),
    Recipe(
        id: UUID(),
        name: "Beef Stir Fry",
        ingredients: ["beef sirloin", "broccoli", "carrot", "soy sauce", "garlic", "ginger", "vegetable oil", "rice"],
        dietaryTags: [],
        cookingTime: "20 minutes",
        instructions: [
            "Cook rice according to package directions.",
            "Stir-fry beef until browned, add vegetables.",
            "Add soy sauce, garlic, and ginger, cook until vegetables are tender."
        ],
        ingredientAmounts: ["beef sirloin": "1 lb", "broccoli": "2 cups", "carrot": "2", "soy sauce": "3 tbsp", "garlic": "3 cloves", "ginger": "1 tbsp", "vegetable oil": "2 tbsp", "rice": "2 cups"],
        isAIGenerated: false,
        difficulty: "Medium",
        steps: [
            RecipeStep(name: "Cook rice according to package directions", duration: 600),
            RecipeStep(name: "Stir-fry beef until browned", duration: 300),
            RecipeStep(name: "Add vegetables", duration: 120),
            RecipeStep(name: "Add soy sauce, garlic, and ginger", duration: 180),
            RecipeStep(name: "Cook until vegetables are tender", duration: 120)
        ]
    ),
    Recipe(
        id: UUID(),
        name: "Salmon with Lemon",
        ingredients: ["salmon fillet", "lemon", "garlic", "butter", "parsley", "salt", "pepper", "olive oil"],
        dietaryTags: [],
        cookingTime: "15 minutes",
        instructions: [
            "Season salmon with salt and pepper.",
            "Sear salmon in olive oil, add lemon, garlic, butter, and parsley."
        ],
        ingredientAmounts: ["salmon fillet": "4", "lemon": "2", "garlic": "4 cloves", "butter": "2 tbsp", "parsley": "2 tbsp", "salt": "to taste", "pepper": "to taste", "olive oil": "2 tbsp"],
        isAIGenerated: false,
        difficulty: "Easy",
        steps: [
            RecipeStep(name: "Season salmon with salt and pepper", duration: 60),
            RecipeStep(name: "Sear salmon in olive oil", duration: 300),
            RecipeStep(name: "Add lemon, garlic, butter, and parsley", duration: 120),
            RecipeStep(name: "Cook until salmon is flaky", duration: 180)
        ]
    ),
    Recipe(
        id: UUID(),
        name: "Vegetable Soup",
        ingredients: ["carrot", "celery", "onion", "potato", "tomato", "vegetable broth", "garlic", "parsley"],
        dietaryTags: ["vegetarian", "vegan"],
        cookingTime: "45 minutes",
        instructions: [
            "Sauté onion, carrot, and celery in oil.",
            "Add broth, potatoes, tomatoes, and garlic. Simmer until vegetables are tender."
        ],
        ingredientAmounts: ["carrot": "4", "celery": "4 stalks", "onion": "2", "potato": "3", "tomato": "4", "vegetable broth": "8 cups", "garlic": "4 cloves", "parsley": "1/4 cup"],
        isAIGenerated: false,
        difficulty: "Easy",
        steps: [
            RecipeStep(name: "Sauté onion, carrot, and celery in oil", duration: 300),
            RecipeStep(name: "Add broth, potatoes, tomatoes, and garlic", duration: 120),
            RecipeStep(name: "Simmer until vegetables are tender", duration: 1800),
            RecipeStep(name: "Garnish with parsley", duration: 30)
        ]
    ),
    Recipe(
        id: UUID(),
        name: "Chicken Alfredo",
        ingredients: ["fettuccine", "chicken breast", "heavy cream", "parmesan cheese", "garlic", "butter", "parsley", "black pepper"],
        dietaryTags: [],
        cookingTime: "25 minutes",
        instructions: [
            "Cook fettuccine, grill chicken.",
            "Make sauce with cream, parmesan, garlic, and butter. Toss with pasta and chicken."
        ],
        ingredientAmounts: ["fettuccine": "1 lb", "chicken breast": "1 lb", "heavy cream": "2 cups", "parmesan cheese": "1 cup", "garlic": "4 cloves", "butter": "4 tbsp", "parsley": "2 tbsp", "black pepper": "to taste"],
        isAIGenerated: false,
        difficulty: "Medium",
        steps: [
            RecipeStep(name: "Cook fettuccine", duration: 600),
            RecipeStep(name: "Grill chicken", duration: 600),
            RecipeStep(name: "Make sauce with cream, parmesan, garlic, and butter", duration: 300),
            RecipeStep(name: "Toss with pasta and chicken", duration: 120)
        ]
    ),
    Recipe(
        id: UUID(),
        name: "Tuna Salad",
        ingredients: ["tuna", "mayonnaise", "celery", "onion", "lemon", "salt", "pepper", "bread"],
        dietaryTags: [],
        cookingTime: "10 minutes",
        instructions: [
            "Drain tuna, mix with mayonnaise, celery, onion, lemon, salt, and pepper.",
            "Serve on bread or lettuce."
        ],
        ingredientAmounts: ["tuna": "2 cans", "mayonnaise": "1/2 cup", "celery": "2 stalks", "onion": "1/2", "lemon": "1/2", "salt": "to taste", "pepper": "to taste", "bread": "8 slices"],
        isAIGenerated: false,
        difficulty: "Easy",
        steps: [
            RecipeStep(name: "Drain tuna", duration: 30),
            RecipeStep(name: "Mix with mayonnaise, celery, onion, lemon, salt, and pepper", duration: 300),
            RecipeStep(name: "Serve on bread or lettuce", duration: 60)
        ]
    ),
    Recipe(
        id: UUID(),
        name: "Breakfast Burrito",
        ingredients: ["egg", "tortilla", "cheese", "bacon", "potato", "onion", "bell pepper", "salsa"],
        dietaryTags: [],
        cookingTime: "20 minutes",
        instructions: [
            "Scramble eggs, cook bacon and potatoes.",
            "Warm tortilla, fill with eggs, bacon, potatoes, cheese, and salsa."
        ],
        ingredientAmounts: ["egg": "6", "tortilla": "4", "cheese": "1 cup", "bacon": "8 strips", "potato": "2", "onion": "1", "bell pepper": "1", "salsa": "1/2 cup"],
        isAIGenerated: false,
        difficulty: "Medium",
        steps: [
            RecipeStep(name: "Scramble eggs", duration: 300),
            RecipeStep(name: "Cook bacon and potatoes", duration: 600),
            RecipeStep(name: "Warm tortilla", duration: 120),
            RecipeStep(name: "Fill with eggs, bacon, potatoes, cheese, and salsa", duration: 180)
        ]
    ),
    Recipe(
        id: UUID(),
        name: "Pasta Salad",
        ingredients: ["penne pasta", "cucumber", "tomato", "olive", "feta cheese", "olive oil", "lemon", "basil"],
        dietaryTags: ["vegetarian"],
        cookingTime: "20 minutes",
        instructions: [
            "Cook pasta, let cool.",
            "Mix with chopped vegetables, olives, feta, olive oil, lemon, and basil."
        ],
        ingredientAmounts: ["penne pasta": "1 lb", "cucumber": "1", "tomato": "2", "olive": "1/2 cup", "feta cheese": "1 cup", "olive oil": "1/4 cup", "lemon": "1", "basil": "1/4 cup"],
        isAIGenerated: false,
        difficulty: "Easy",
        steps: [
            RecipeStep(name: "Cook pasta", duration: 600),
            RecipeStep(name: "Let pasta cool", duration: 300),
            RecipeStep(name: "Mix with chopped vegetables, olives, feta, olive oil, lemon, and basil", duration: 300)
        ]
    ),
    Recipe(
        id: UUID(),
        name: "Chicken Wings",
        ingredients: ["chicken wings", "hot sauce", "butter", "garlic", "celery", "blue cheese", "ranch dressing"],
        dietaryTags: [],
        cookingTime: "45 minutes",
        instructions: [
            "Season wings, bake until crispy.",
            "Make sauce with hot sauce, butter, and garlic. Toss wings in sauce, serve with celery and dressing."
        ],
        ingredientAmounts: ["chicken wings": "2 lbs", "hot sauce": "1/2 cup", "butter": "1/2 cup", "garlic": "4 cloves", "celery": "1 bunch", "blue cheese": "1 cup", "ranch dressing": "1 cup"],
        isAIGenerated: false,
        difficulty: "Medium",
        steps: [
            RecipeStep(name: "Season wings", duration: 120),
            RecipeStep(name: "Bake until crispy", duration: 2400),
            RecipeStep(name: "Make sauce with hot sauce, butter, and garlic", duration: 180),
            RecipeStep(name: "Toss wings in sauce", duration: 120),
            RecipeStep(name: "Serve with celery and dressing", duration: 60)
        ]
    ),
    Recipe(
        id: UUID(),
        name: "Vegetable Stir Fry",
        ingredients: ["broccoli", "carrot", "bell pepper", "snow peas", "garlic", "ginger", "soy sauce", "rice"],
        dietaryTags: ["vegetarian", "vegan"],
        cookingTime: "15 minutes",
        instructions: [
            "Cook rice according to package directions.",
            "Stir-fry vegetables with garlic, ginger, and soy sauce until tender."
        ],
        ingredientAmounts: ["broccoli": "2 cups", "carrot": "2", "bell pepper": "2", "snow peas": "2 cups", "garlic": "4 cloves", "ginger": "1 tbsp", "soy sauce": "3 tbsp", "rice": "2 cups"],
        isAIGenerated: false,
        difficulty: "Easy",
        steps: [
            RecipeStep(name: "Cook rice according to package directions", duration: 600),
            RecipeStep(name: "Stir-fry vegetables with garlic, ginger, and soy sauce", duration: 300),
            RecipeStep(name: "Cook until vegetables are tender", duration: 120)
        ]
    ),
    Recipe(
        id: UUID(),
        name: "Beef Tacos",
        ingredients: ["ground beef", "taco seasoning", "tortilla", "lettuce", "tomato", "cheese", "sour cream", "onion"],
        dietaryTags: [],
        cookingTime: "15 minutes",
        instructions: [
            "Cook ground beef with taco seasoning.",
            "Warm tortillas, assemble with beef, lettuce, tomato, cheese, sour cream, and onion."
        ],
        ingredientAmounts: ["ground beef": "1 lb", "taco seasoning": "1 packet", "tortilla": "8", "lettuce": "2 cups", "tomato": "2", "cheese": "1 cup", "sour cream": "1/2 cup", "onion": "1"],
        isAIGenerated: false,
        difficulty: "Easy",
        steps: [
            RecipeStep(name: "Cook ground beef with taco seasoning", duration: 300),
            RecipeStep(name: "Warm tortillas", duration: 120),
            RecipeStep(name: "Assemble with beef, lettuce, tomato, cheese, sour cream, and onion", duration: 180)
        ]
    ),
    // MARK: - Additional Breakfast Recipes
    Recipe(
        id: UUID(),
        name: "French Toast",
        ingredients: ["bread", "eggs", "milk", "vanilla", "cinnamon", "butter", "maple syrup"],
        dietaryTags: ["vegetarian"],
        cookingTime: "15 minutes",
        instructions: [
            "Whisk eggs, milk, vanilla, and cinnamon.",
            "Dip bread slices in mixture.",
            "Cook in buttered pan until golden. Serve with syrup."
        ],
        ingredientAmounts: ["bread": "8 slices", "eggs": "3", "milk": "1/2 cup", "vanilla": "1 tsp", "cinnamon": "1/2 tsp", "butter": "2 tbsp", "maple syrup": "1/2 cup"],
        isAIGenerated: false,
        difficulty: "Easy",
        steps: [
            RecipeStep(name: "Whisk eggs, milk, vanilla, and cinnamon", duration: 120),
            RecipeStep(name: "Dip bread slices in mixture", duration: 180),
            RecipeStep(name: "Cook in buttered pan until golden", duration: 480),
            RecipeStep(name: "Serve with maple syrup", duration: 60)
        ]
    ),
    Recipe(
        id: UUID(),
        name: "Overnight Oats",
        ingredients: ["oats", "milk", "yogurt", "honey", "berries", "chia seeds", "vanilla"],
        dietaryTags: ["vegetarian", "healthy"],
        cookingTime: "5 minutes prep",
        instructions: [
            "Mix oats, milk, yogurt, honey, and chia seeds.",
            "Refrigerate overnight.",
            "Top with berries before serving."
        ],
        ingredientAmounts: ["oats": "1 cup", "milk": "1 cup", "yogurt": "1/2 cup", "honey": "2 tbsp", "berries": "1 cup", "chia seeds": "2 tbsp", "vanilla": "1 tsp"],
        isAIGenerated: false,
        difficulty: "Easy",
        steps: [
            RecipeStep(name: "Mix oats, milk, yogurt, honey, chia seeds, and vanilla", duration: 180),
            RecipeStep(name: "Refrigerate overnight", duration: 28800),
            RecipeStep(name: "Top with berries before serving", duration: 60)
        ]
    ),
    Recipe(
        id: UUID(),
        name: "Eggs Benedict",
        ingredients: ["english muffins", "eggs", "ham", "butter", "egg yolks", "lemon juice", "cayenne"],
        dietaryTags: [],
        cookingTime: "25 minutes",
        instructions: [
            "Toast English muffins.",
            "Poach eggs and warm ham.",
            "Make hollandaise sauce.",
            "Assemble and serve immediately."
        ],
        ingredientAmounts: ["english muffins": "4 halves", "eggs": "4", "ham": "4 slices", "butter": "1/2 cup", "egg yolks": "3", "lemon juice": "2 tbsp", "cayenne": "pinch"],
        isAIGenerated: false,
        difficulty: "Hard",
        steps: [
            RecipeStep(name: "Toast English muffins", duration: 180),
            RecipeStep(name: "Poach eggs", duration: 480),
            RecipeStep(name: "Warm ham slices", duration: 120),
            RecipeStep(name: "Make hollandaise sauce", duration: 600),
            RecipeStep(name: "Assemble and serve immediately", duration: 120)
        ]
    ),
    // MARK: - Additional Lunch Recipes
    Recipe(
        id: UUID(),
        name: "Club Sandwich",
        ingredients: ["bread", "turkey", "bacon", "lettuce", "tomato", "mayonnaise", "avocado"],
        dietaryTags: [],
        cookingTime: "15 minutes",
        instructions: [
            "Toast bread slices.",
            "Cook bacon until crispy.",
            "Layer turkey, bacon, lettuce, tomato, avocado with mayo.",
            "Secure with toothpicks and cut diagonally."
        ],
        ingredientAmounts: ["bread": "6 slices", "turkey": "8 oz", "bacon": "6 strips", "lettuce": "4 leaves", "tomato": "1 large", "mayonnaise": "3 tbsp", "avocado": "1"],
        isAIGenerated: false,
        difficulty: "Easy",
        steps: [
            RecipeStep(name: "Toast bread slices", duration: 180),
            RecipeStep(name: "Cook bacon until crispy", duration: 480),
            RecipeStep(name: "Layer ingredients with mayo", duration: 300),
            RecipeStep(name: "Secure with toothpicks and cut", duration: 120)
        ]
    ),
    Recipe(
        id: UUID(),
        name: "Chicken Caesar Wrap",
        ingredients: ["tortilla", "chicken breast", "romaine lettuce", "parmesan", "caesar dressing", "croutons"],
        dietaryTags: [],
        cookingTime: "20 minutes",
        instructions: [
            "Cook and slice chicken breast.",
            "Mix lettuce with caesar dressing.",
            "Add chicken and parmesan to tortilla.",
            "Roll tightly and slice in half."
        ],
        ingredientAmounts: ["tortilla": "2 large", "chicken breast": "1 lb", "romaine lettuce": "2 cups", "parmesan": "1/2 cup", "caesar dressing": "1/4 cup", "croutons": "1/2 cup"],
        isAIGenerated: false,
        difficulty: "Medium",
        steps: [
            RecipeStep(name: "Cook chicken breast thoroughly", duration: 720),
            RecipeStep(name: "Slice cooked chicken", duration: 180),
            RecipeStep(name: "Mix lettuce with caesar dressing", duration: 120),
            RecipeStep(name: "Assemble wrap with chicken and parmesan", duration: 180),
            RecipeStep(name: "Roll tightly and slice in half", duration: 120)
        ]
    ),
    // MARK: - Additional Dinner Recipes
    Recipe(
        id: UUID(),
        name: "Baked Salmon",
        ingredients: ["salmon fillets", "olive oil", "lemon", "garlic", "dill", "salt", "pepper", "asparagus"],
        dietaryTags: ["healthy", "gluten-free"],
        cookingTime: "25 minutes",
        instructions: [
            "Preheat oven to 400°F.",
            "Season salmon with oil, lemon, garlic, dill, salt, pepper.",
            "Bake with asparagus for 12-15 minutes."
        ],
        ingredientAmounts: ["salmon fillets": "4", "olive oil": "3 tbsp", "lemon": "1", "garlic": "3 cloves", "dill": "2 tbsp", "salt": "to taste", "pepper": "to taste", "asparagus": "1 lb"],
        isAIGenerated: false,
        difficulty: "Medium",
        steps: [
            RecipeStep(name: "Preheat oven to 400°F", duration: 300),
            RecipeStep(name: "Season salmon with oil, lemon, garlic, dill", duration: 300),
            RecipeStep(name: "Prepare asparagus", duration: 180),
            RecipeStep(name: "Bake salmon and asparagus", duration: 900),
            RecipeStep(name: "Check doneness and serve", duration: 120)
        ]
    ),
    Recipe(
        id: UUID(),
        name: "Beef Steak with Mashed Potatoes",
        ingredients: ["ribeye steak", "potatoes", "butter", "milk", "garlic", "rosemary", "salt", "pepper"],
        dietaryTags: [],
        cookingTime: "35 minutes",
        instructions: [
            "Season steaks with salt, pepper, garlic, rosemary.",
            "Boil and mash potatoes with butter and milk.",
            "Sear steaks in hot pan to desired doneness.",
            "Let steaks rest, then serve with mashed potatoes."
        ],
        ingredientAmounts: ["ribeye steak": "2", "potatoes": "2 lbs", "butter": "6 tbsp", "milk": "1/2 cup", "garlic": "4 cloves", "rosemary": "2 sprigs", "salt": "to taste", "pepper": "to taste"],
        isAIGenerated: false,
        difficulty: "Medium",
        steps: [
            RecipeStep(name: "Season steaks with salt, pepper, garlic, rosemary", duration: 300),
            RecipeStep(name: "Boil potatoes until tender", duration: 1200),
            RecipeStep(name: "Mash potatoes with butter and milk", duration: 300),
            RecipeStep(name: "Sear steaks in hot pan", duration: 480),
            RecipeStep(name: "Let steaks rest, then serve", duration: 300)
        ]
    ),
    Recipe(
        id: UUID(),
        name: "Vegetarian Pad Thai",
        ingredients: ["rice noodles", "tofu", "eggs", "bean sprouts", "carrots", "peanuts", "lime", "soy sauce", "fish sauce", "sugar"],
        dietaryTags: ["vegetarian"],
        cookingTime: "25 minutes",
        instructions: [
            "Soak rice noodles in warm water.",
            "Stir-fry tofu until golden.",
            "Add eggs, then vegetables.",
            "Toss with noodles and sauce, garnish with peanuts and lime."
        ],
        ingredientAmounts: ["rice noodles": "8 oz", "tofu": "8 oz", "eggs": "2", "bean sprouts": "2 cups", "carrots": "1", "peanuts": "1/4 cup", "lime": "2", "soy sauce": "3 tbsp", "fish sauce": "2 tbsp", "sugar": "2 tbsp"],
        isAIGenerated: false,
        difficulty: "Medium",
        steps: [
            RecipeStep(name: "Soak rice noodles in warm water", duration: 600),
            RecipeStep(name: "Stir-fry tofu until golden", duration: 360),
            RecipeStep(name: "Scramble eggs in the pan", duration: 180),
            RecipeStep(name: "Add vegetables and stir-fry", duration: 240),
            RecipeStep(name: "Toss with noodles and sauce", duration: 180),
            RecipeStep(name: "Garnish with peanuts and lime", duration: 120)
        ]
    ),
    // MARK: - International Recipes
    Recipe(
        id: UUID(),
        name: "Chicken Tikka Masala",
        ingredients: ["chicken breast", "yogurt", "garam masala", "turmeric", "tomatoes", "cream", "onion", "ginger", "garlic", "rice"],
        dietaryTags: [],
        cookingTime: "45 minutes",
        instructions: [
            "Marinate chicken in yogurt and spices.",
            "Cook chicken until charred.",
            "Make sauce with tomatoes, cream, and spices.",
            "Simmer chicken in sauce, serve over rice."
        ],
        ingredientAmounts: ["chicken breast": "2 lbs", "yogurt": "1 cup", "garam masala": "2 tbsp", "turmeric": "1 tsp", "tomatoes": "1 can", "cream": "1/2 cup", "onion": "1", "ginger": "2 tbsp", "garlic": "4 cloves", "rice": "2 cups"],
        isAIGenerated: false,
        difficulty: "Medium",
        steps: [
            RecipeStep(name: "Marinate chicken in yogurt and spices", duration: 1800),
            RecipeStep(name: "Cook rice", duration: 1200),
            RecipeStep(name: "Cook marinated chicken until charred", duration: 600),
            RecipeStep(name: "Sauté onion, ginger, garlic", duration: 300),
            RecipeStep(name: "Add tomatoes and simmer sauce", duration: 600),
            RecipeStep(name: "Add cream and chicken, simmer", duration: 480),
            RecipeStep(name: "Serve over rice", duration: 120)
        ]
    ),
    Recipe(
        id: UUID(),
        name: "Fish and Chips",
        ingredients: ["white fish", "potatoes", "flour", "beer", "baking powder", "salt", "oil", "malt vinegar"],
        dietaryTags: [],
        cookingTime: "30 minutes",
        instructions: [
            "Cut potatoes into chips and soak.",
            "Make beer batter with flour, beer, baking powder.",
            "Deep fry chips until golden.",
            "Coat fish in batter and fry. Serve with vinegar."
        ],
        ingredientAmounts: ["white fish": "1.5 lbs", "potatoes": "2 lbs", "flour": "2 cups", "beer": "1 cup", "baking powder": "1 tsp", "salt": "2 tsp", "oil": "for frying", "malt vinegar": "to taste"],
        isAIGenerated: false,
        difficulty: "Hard",
        steps: [
            RecipeStep(name: "Cut potatoes into chips and soak", duration: 600),
            RecipeStep(name: "Heat oil to 350°F", duration: 300),
            RecipeStep(name: "Make beer batter", duration: 180),
            RecipeStep(name: "Fry chips until golden", duration: 600),
            RecipeStep(name: "Coat fish in batter and fry", duration: 480),
            RecipeStep(name: "Drain and serve with vinegar", duration: 180)
        ]
    ),
    // MARK: - Dessert Recipes
    Recipe(
        id: UUID(),
        name: "Chocolate Brownies",
        ingredients: ["dark chocolate", "butter", "sugar", "eggs", "flour", "cocoa powder", "vanilla", "walnuts"],
        dietaryTags: ["vegetarian"],
        cookingTime: "35 minutes",
        instructions: [
            "Melt chocolate and butter.",
            "Beat in sugar and eggs.",
            "Fold in flour and cocoa.",
            "Bake until set but fudgy."
        ],
        ingredientAmounts: ["dark chocolate": "8 oz", "butter": "1/2 cup", "sugar": "1 cup", "eggs": "3", "flour": "3/4 cup", "cocoa powder": "1/4 cup", "vanilla": "1 tsp", "walnuts": "1 cup"],
        isAIGenerated: false,
        difficulty: "Medium",
        steps: [
            RecipeStep(name: "Preheat oven to 350°F", duration: 300),
            RecipeStep(name: "Melt chocolate and butter", duration: 300),
            RecipeStep(name: "Beat in sugar and eggs", duration: 240),
            RecipeStep(name: "Fold in flour, cocoa, and walnuts", duration: 180),
            RecipeStep(name: "Bake until set but fudgy", duration: 1500),
            RecipeStep(name: "Cool before cutting", duration: 1200)
        ]
    ),
    Recipe(
        id: UUID(),
        name: "Cheesecake",
        ingredients: ["graham crackers", "butter", "cream cheese", "sugar", "eggs", "vanilla", "sour cream"],
        dietaryTags: ["vegetarian"],
        cookingTime: "1 hour 30 minutes",
        instructions: [
            "Make graham cracker crust.",
            "Beat cream cheese until smooth.",
            "Add sugar, eggs, vanilla.",
            "Bake in water bath, chill overnight."
        ],
        ingredientAmounts: ["graham crackers": "1.5 cups crumbs", "butter": "1/3 cup", "cream cheese": "32 oz", "sugar": "1 cup", "eggs": "4", "vanilla": "2 tsp", "sour cream": "1 cup"],
        isAIGenerated: false,
        difficulty: "Hard",
        steps: [
            RecipeStep(name: "Make graham cracker crust", duration: 300),
            RecipeStep(name: "Press crust in pan and pre-bake", duration: 600),
            RecipeStep(name: "Beat cream cheese until smooth", duration: 300),
            RecipeStep(name: "Add sugar, eggs, vanilla", duration: 360),
            RecipeStep(name: "Pour over crust", duration: 120),
            RecipeStep(name: "Bake in water bath", duration: 3600),
            RecipeStep(name: "Cool completely", duration: 7200),
            RecipeStep(name: "Chill overnight", duration: 28800)
        ]
    )
]

class CookNowStep: ObservableObject, Identifiable, Equatable {
    let id = UUID()
    let name: String
    let duration: TimeInterval
    @Published var remaining: TimeInterval
    @Published var isCompleted: Bool = false
    @Published var isSkipped: Bool = false
    
    init(name: String, duration: TimeInterval) {
        self.name = name
        self.duration = duration
        self.remaining = duration
    }
    
    static func == (lhs: CookNowStep, rhs: CookNowStep) -> Bool {
        lhs.id == rhs.id
    }
}

class CookNowTimerManager: ObservableObject {
    @Published var steps: [CookNowStep]
    @Published var currentStepIndex: Int = 0
    @Published var isPaused: Bool = false
    @Published var isComplete: Bool = false
    private var timer: AnyCancellable?

    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
    private var currentRecipeName: String = ""
    private var backgroundTimer: Timer? = nil
    private var isTimerRunning = false
    
    var currentStep: CookNowStep? {
        guard steps.indices.contains(currentStepIndex) else { return nil }
        return steps[currentStepIndex]
    }
    
    init(steps: [RecipeStep], recipeName: String = "") {
        self.steps = steps.map { CookNowStep(name: $0.name, duration: $0.duration) }
        self.currentRecipeName = recipeName
        
        // Listen for app state changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }
    
    func start() {
        print("CookNowTimerManager: Starting timer...")
        isPaused = false
        isComplete = false
        
        startTimer()
        print("CookNowTimerManager: Timer started successfully")
    }
    
    private func startTimer() {
        timer?.cancel()
        
        // Store start time for time-based calculations
        // Only set timer start time if this is a new step (remaining == duration)
        if let step = currentStep, step.remaining == step.duration {
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "timerStartTime")
        }
        
        // Use a single, stable timer for long-term reliability
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.tick()
                }
            }
        
        // Start background task to keep timer alive
        startBackgroundTask()
    }
    
    func pause() {
        isPaused = true
        timer?.cancel()
        backgroundTimer?.invalidate()
    }
    
    func resume() {
        isPaused = false
        // Reset the start time to account for the pause duration
        if let step = currentStep {
            let remainingTime = step.remaining
            let currentTime = Date().timeIntervalSince1970
            let newStartTime = currentTime - (step.duration - remainingTime)
            UserDefaults.standard.set(newStartTime, forKey: "timerStartTime")
        }
        startTimer()
    }
    
    func skip() {
        if currentStepIndex == steps.count - 1 {
            // If skipping the final step, complete immediately
            isComplete = true
            timer?.cancel()
        } else {
            currentStep?.isSkipped = true
            nextStep()
        }
    }
    
    func nextStep() {
        timer?.cancel()
        if currentStepIndex + 1 < steps.count {
            currentStepIndex += 1
            print("[nextStep] Advanced to step index: \(currentStepIndex), step name: \(currentStep?.name ?? "?") at \(Date())")
            // Reset the start time for the new step to prevent skipping
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "timerStartTime")
            startTimer()
        } else {
            // Recipe complete
            isComplete = true
            timer?.cancel()
        }
    }
    
    private func tick() {
        guard !isPaused, let step = currentStep, !step.isCompleted, !step.isSkipped else { return }
        
        // Simple, reliable time decrement - no complex calculations
        step.remaining = max(step.remaining - 1, 0)
        
        // Check if step is complete
        if step.remaining <= 0 {
            step.isCompleted = true
            if currentStepIndex == steps.count - 1 {
                // Last step finished
                isComplete = true
                timer?.cancel()
            } else {
                nextStep()
            }
            return
        }
        
        // Renew background task every tick to keep it alive
        renewBackgroundTask()
        
        // Store last update time for freeze detection
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "lastTimerUpdate")
        
        // Store current step progress for recovery
        UserDefaults.standard.set(step.remaining, forKey: "currentStepRemaining")
        UserDefaults.standard.set(currentStepIndex, forKey: "currentStepIndex")
        
    }
    
    func stop() {
        timer?.cancel()
        backgroundTimer?.invalidate()
        backgroundTimer = nil
        endBackgroundTask()
    }
    

    
    // MARK: - Background Task Management
    private func startBackgroundTask() {
        // End any existing background task first
        endBackgroundTask()
        
        // Start a new background task with proper expiration handling
        backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "CookNowTimer") { [weak self] in
            // This closure is called when background time is about to expire
            print("Background task expiring, ending gracefully...")
            
            // Save current state before ending
            if let step = self?.currentStep {
                UserDefaults.standard.set(step.remaining, forKey: "savedStepRemaining")
                UserDefaults.standard.set(self?.currentStepIndex ?? 0, forKey: "savedStepIndex")
            }
            
            self?.endBackgroundTask()
        }
    }
    
    private func endBackgroundTask() {
        if backgroundTaskID != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = .invalid
            print("Background task ended properly")
        }
    }
    
    private func renewBackgroundTask() {
        // Only renew if we're still cooking and not paused
        guard !isPaused && !isComplete else {
            endBackgroundTask()
            return
        }
        
        // End current background task and start a new one to extend execution time
        if backgroundTaskID != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = .invalid
        }
        
        // Start a new background task
        startBackgroundTask()
    }
    

    
    private func getEstimatedFinishTime() -> String {
        guard let step = currentStep else { return "" }
        
        let totalRemainingSeconds = step.remaining + getRemainingTimeForAllSteps()
        let finishDate = Date().addingTimeInterval(totalRemainingSeconds)
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: finishDate)
    }
    
    private func getTotalRemainingTime() -> TimeInterval {
        guard let step = currentStep else { return 0 }
        return step.remaining + getRemainingTimeForAllSteps()
    }
    
    private func getRemainingTimeForAllSteps() -> TimeInterval {
        var totalRemaining: TimeInterval = 0
        
        // Add remaining time for current step
        if let currentStep = currentStep {
            totalRemaining += currentStep.remaining
        }
        
        // Add time for remaining steps
        for i in (currentStepIndex + 1)..<steps.count {
            totalRemaining += steps[i].duration
        }
        
        return totalRemaining
    }
    
    private func getCurrentRecipeName() -> String {
        return currentRecipeName.isEmpty ? "Cooking Recipe" : currentRecipeName
    }
    
    // MARK: - Button Action Handlers
    @objc private func handleTogglePause() {
        DispatchQueue.main.async {
            if self.isPaused {
                self.resume()
            } else {
                self.pause()
            }
        }
    }
    
    @objc private func handleSkipStep() {
        DispatchQueue.main.async {
            self.skip()
        }
    }
    
    @objc private func handleAppDidBecomeActive() {
        // App became active - ensure timer is running
        if !isPaused && !isComplete {
            // Timer is running normally
        }
    }
    
    @objc private func handleAppWillResignActive() {
        // App is about to become inactive - ensure background task is active
        if !isPaused && !isComplete {
            renewBackgroundTask()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

struct RecipeCard: View {
    let recipe: Recipe
    let isFavorite: Bool
    var onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(recipe.name)
                .font(.title2.bold())
            HStack {
                ForEach(recipe.dietaryTags.prefix(2), id: \.self) { tag in
                    Text(tag)
                        .font(.caption.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.orange.opacity(0.1))
                        .clipShape(Capsule())
                        .foregroundColor(.orange)
                }
                Spacer()
                Text(recipe.cookingTime)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 4)
            Text("Includes: " + recipe.ingredients.prefix(4).joined(separator: ", ") + "...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(24)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
        .onTapGesture(perform: onTap)
    }
}

// MARK: - Unsplash API Networking
struct UnsplashPhotoURLs: Decodable {
    let regular: String
}

struct UnsplashPhoto: Decodable {
    let urls: UnsplashPhotoURLs
    let user: UnsplashUser
    let links: UnsplashPhotoLinks
}

struct UnsplashUser: Decodable {
    let name: String
    let links: UnsplashUserLinks
}

struct UnsplashUserLinks: Decodable {
    let html: String
}

struct UnsplashPhotoLinks: Decodable {
    let download_location: String
}

struct UnsplashSearchResponse: Decodable {
    let results: [UnsplashPhoto]
}

func fetchUnsplashImageInfo(for query: String, apiKey: String, completion: @escaping (String?, String?, String?, String?) -> Void) {
    let queryEncoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
    let urlString = "https://api.unsplash.com/search/photos?query=\(queryEncoded)&per_page=1&client_id=\(apiKey)"
    guard let url = URL(string: urlString) else {
        completion(nil, nil, nil, nil)
        return
    }
    URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data, error == nil else {
            completion(nil, nil, nil, nil)
            return
        }
        do {
            let decoded = try JSONDecoder().decode(UnsplashSearchResponse.self, from: data)
            if let photo = decoded.results.first {
                let imageURL = photo.urls.regular
                let photographerName = photo.user.name
                let photographerURL = photo.user.links.html
                let downloadLocation = photo.links.download_location
                completion(imageURL, photographerName, photographerURL, downloadLocation)
            } else {
                completion(nil, nil, nil, nil)
            }
        } catch {
            completion(nil, nil, nil, nil)
        }
    }.resume()
}

// Call this endpoint to trigger a download event
func triggerUnsplashDownload(downloadLocation: String, apiKey: String) {
    guard let url = URL(string: downloadLocation + "?client_id=\(apiKey)") else { return }
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    URLSession.shared.dataTask(with: request) { _, _, _ in }.resume()
} 