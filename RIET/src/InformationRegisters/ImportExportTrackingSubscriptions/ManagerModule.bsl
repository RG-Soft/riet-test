
Процедура ОбработкаПолученияФормы(ВидФормы, Параметры, ВыбраннаяФорма, ДополнительнаяИнформация, СтандартнаяОбработка)
	
	Если ВидФормы = "ФормаЗаписи" Тогда
	
		СтандартнаяОбработка = Ложь;
		
		этоDPM = Ложь;
		
		Если Параметры.Свойство("Ключ") И Параметры.Ключ.ProjectMobilizationSubscribe Тогда
			этоDPM = Истина;
		КонецЕсли;
		
		Если Параметры.Свойство("ЗначенияЗаполнения") И Параметры.ЗначенияЗаполнения.Свойство("ProjectMobilizationSubscribe") И Параметры.ЗначенияЗаполнения.ProjectMobilizationSubscribe Тогда
			этоDPM = Истина;
		КонецЕсли;
		
		Если этоDPM Тогда
			
			ВыбраннаяФорма = "ФормаЗаписиDPM";	
			
		Иначе
		
			ВыбраннаяФорма = "ФормаЗаписи";	
			
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры