
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Отбор = Параметры.Отбор;
	Если НЕ Отбор.Свойство("ПометкаУдаления") Тогда
		Отбор.Вставить("ПометкаУдаления", Ложь);
	КонецЕсли;
	
КонецПроцедуры
