
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Отбор = Параметры.Отбор;		
	ImportExportСервер.ДобавитьОтборПоProcessLevel(Отбор);
	Отбор.Вставить("ПометкаУдаления", Ложь);
	
КонецПроцедуры
