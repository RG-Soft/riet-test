
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если НЕ Параметры.Отбор.Свойство("ПометкаУдаления") Тогда
		Параметры.Отбор.Вставить("ПометкаУдаления", Ложь);
	КонецЕсли;
	
КонецПроцедуры
