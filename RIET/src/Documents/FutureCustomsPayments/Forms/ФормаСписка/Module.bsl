
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Отбор = Параметры.Отбор;
	
	Отбор.Вставить("ПометкаУдаления", Ложь);
	
	ImportExportСервер.ДобавитьОтборПоProcessLevel(Отбор, "ProcessLevel");
		
КонецПроцедуры
