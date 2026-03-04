extends Node

var questions = {
	"easy": [
		{
			"text": "How many seasons does the Philippines have?",
			"options": ["Two (Wet & Dry)", "Four (Spring, Summer, Fall, Winter)", "Three", "One"],
			"correct": 0,
			"hint": "Think about the main types of weather we experience."
		},
		{
			"text": "Which season brings heavy rains?",
			"options": ["Dry Season", "Wet Season", "Cold Season", "Hot Season"],
			"correct": 1,
			"hint": "The name tells you about the weather!"
		},
		{
			"text": "What is the hottest month in the Philippines?",
			"options": ["May", "December", "January", "September"],
			"correct": 0,
			"hint": "It's during the summer vacation."
		},
		{
			"text": "What is weather?",
			"options": ["Condition of a place over a short time", "Long-term climate", "Always sunny", "Never changes"],
			"correct": 0,
			"hint": "Weather can change every day!"
		},
		{
			"text": "What are the two pronounced seasons in the Philippines?",
			"options": ["Wet and Dry", "Summer and Winter", "Spring and Fall", "Cold and Snowy"],
			"correct": 0,
			"hint": "They are based on rainfall."
		},
		{
			"text": "What does climate refer to?",
			"options": ["Long-term average weather", "Daily temperature", "Today’s rain", "Wind speed only"],
			"correct": 0,
			"hint": "It describes weather over many years."
		},
		{
			"text": "Which season is best for planting crops?",
			"options": ["Wet Season", "Dry Season", "Cool Season", "Winter"],
			"correct": 0,
			"hint": "Farmers need rain for crops."
		},
		{
			"text": "Where is the Philippines located?",
			"options": ["Near the Equator", "Near the North Pole", "In Europe", "In Antarctica"],
			"correct": 0,
			"hint": "It is in the tropical region."
		}		
	],
	
	"normal": [
		{
			"text": "What is the Southwest Monsoon called in Filipino?",
			"options": ["Habagat", "Amihan", "Easterlies", "Trade Winds"],
			"correct": 0,
			"hint": "This wind brings rain from May to October."
		},
		{
			"text": "When does the Wet Season peak in the Philippines?",
			"options": ["January to March", "July to September", "November to December", "April to May"],
			"correct": 1,
			"hint": "Think about when typhoons are most common."
		},
		{
			"text": "What influences the seasons in the Philippines?",
			"options": ["Location near Equator and Prevailing Winds", "Distance from the sun", "Ocean currents only", "Mountains"],
			"correct": 0,
			"hint": "The Philippines is in the tropical region."
		},
		{
			"text": "What is the Northeast Monsoon called?",
			"options": ["Amihan", "Habagat", "Typhoon", "Thunder"],
			"correct": 0,
			"hint": "This wind brings cool, dry weather."
		},
		{
			"text": "During which months is the Dry Season in the Philippines?",
			"options": ["June to October", "January to May", "September to December", "All year round"],
			"correct": 1,
			"hint": "Think about when it's very hot and sunny."
		},
		{
			"text": "What are the two main factors affecting seasons in the Philippines?",
			"options": ["Location and Prevailing Winds", "Mountains and Rivers", "Snow and Ice", "Volcanoes only"],
			"correct": 0,
			"hint": "Think about geography and wind patterns."
		},
		{
			"text": "When does the Southwest Monsoon (Habagat) blow?",
			"options": ["May to October", "November to February", "All year round", "January only"],
			"correct": 0,
			"hint": "It happens during the rainy months."
		},
		{
			"text": "When does the Northeast Monsoon (Amihan) blow?",
			"options": ["November to early May", "June to August", "September only", "All year"],
			"correct": 0,
			"hint": "It brings cool and dry winds."
		},
		{
			"text": "What happens during the wettest month of the Wet Season?",
			"options": ["Rain occurs almost daily", "No rain falls", "Snow appears", "Strong drought"],
			"correct": 0,
			"hint": "Expect frequent rainfall."
		},
		{
			"text": "What is a prevailing wind?",
			"options": ["Wind that blows mostly from one direction", "Wind that changes daily", "Wind with no direction", "Very strong storm"],
			"correct": 0,
			"hint": "It usually comes from one main direction."
		}
	],
	
	"hard": [
		{
			"text": "What is the temperature range during the Wet Season daytime?",
			"options": ["30-36°C", "20-25°C", "15-20°C", "40-45°C"],
			"correct": 0,
			"hint": "The air is hot and humid during this season."
		},
		{
			"text": "Which climate type has a pronounced rainy and dry season?",
			"options": ["Type I", "Type II", "Type III", "Type IV"],
			"correct": 0,
			"hint": "This is found in Occidental Mindoro and Palawan."
		},
		{
			"text": "What happens when a warm front moves forward?",
			"options": ["Steady rain", "Clear skies", "Strong winds", "Snow"],
			"correct": 0,
			"hint": "Clouds in the sky bring precipitation."
		},
		{
			"text": "Where does the Northeast Monsoon (Amihan) originate?",
			"options": ["Siberia and Northern China", "Pacific Ocean", "Indian Ocean", "Australia"],
			"correct": 0,
			"hint": "It brings cool and dry winds."
		},
		{
			"text": "What is an occluded front?",
			"options": ["Cold air pushes warm air upward", "Warm air stays at surface", "No air movement", "Hot and cold mix equally"],
			"correct": 0,
			"hint": "Two cold air masses trap warm air between them."
		},
		{
			"text": "Which area receives the highest precipitation from Habagat?",
			"options": ["Southwest regions", "Northeast regions", "Central Luzon", "Northern Mindanao"],
			"correct": 0,
			"hint": "The Southwest Monsoon strikes this area first."
		},
		{
			"text": "What is the nighttime temperature range during the Wet Season?",
			"options": ["21-28°C", "10-15°C", "35-40°C", "0-5°C"],
			"correct": 0,
			"hint": "It stays warm even at night."
		},
		{
			"text": "Which climate type has no pronounced dry season?",
			"options": ["Type II", "Type I", "Type III", "Type IV"],
			"correct": 0,
			"hint": "It has heavy rainfall from November to April."
		},
		{
			"text": "Which climate type has a short dry season and no maximum rain period?",
			"options": ["Type III", "Type I", "Type II", "Type IV"],
			"correct": 0,
			"hint": "Rainfall is not very pronounced."
		},
		{
			"text": "Which climate type lacks a dry season?",
			"options": ["Type IV", "Type I", "Type II", "Type III"],
			"correct": 0,
			"hint": "Rainfall is evenly distributed."
		},
		{
			"text": "What is a stationary front?",
			"options": ["Boundary between air masses that stops moving", "Cold air replacing warm air", "Warm air pushing cold air", "Two hot air masses meeting"],
			"correct": 0,
			"hint": "It stays in the same place for days."
		},
		{
			"text": "What causes severe weather in a cold front?",
			"options": ["Cold air pushes warm air up violently", "Warm air stays below", "No air movement", "Equal air pressure"],
			"correct": 0,
			"hint": "Cold air forces warm air upward quickly."
		},
		{
			"text": "What determines the characteristics of an air mass?",
			"options": ["The region where it forms", "Its color", "Its speed", "Its height only"],
			"correct": 0,
			"hint": "It depends on the Earth's surface where it develops."
		}
	]
}

func get_questions_for_difficulty() -> Array:
	return questions[Settings.difficulty_level].duplicate()

func get_random_question() -> Dictionary:
	var difficulty_questions = get_questions_for_difficulty()
	if difficulty_questions.size() > 0:
		return difficulty_questions.pick_random()
	else:
		print("⚠️ No questions found for difficulty:", Settings.difficulty_level)
		return {}
