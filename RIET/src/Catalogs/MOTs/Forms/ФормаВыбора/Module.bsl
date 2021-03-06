
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("СтруктураНастройки") Тогда
		
		СтруктураНастройки = Параметры.СтруктураНастройки;
		Если СтруктураНастройки.Имя = "ВыборИзEquipment" Тогда
			НастроитьДляВыбораИзEquipment(СтруктураНастройки);
		КонецЕсли;
		
	КонецЕсли;
	
	Если НЕ Параметры.Отбор.Свойство("ПометкаУдаления") Тогда
		Параметры.Отбор.Вставить("ПометкаУдаления", Ложь);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура НастроитьДляВыбораИзEquipment(СтруктураНастройки)
	
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбора(
			Список.Отбор,
			"Ссылка",
			СтруктураНастройки.МассивMOT,
			ВидСравненияКомпоновкиДанных.НеВСписке);
			
КонецПроцедуры