  
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	НастроитьUnpostИSaveDraft();	
	
КонецПроцедуры

&НаСервере
Процедура НастроитьUnpostИSaveDraft()
	
	ImportExportСервер.НастроитьВидимостьUnpostИSave(Элементы.Найти("ФормаОтменаПроведения"), Элементы.Найти("ФормаЗаписать"), Объект.Проведен);
	
КонецПроцедуры

&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	
	РГСофт.ЗаполнитьModification(ТекущийОбъект);
	
КонецПроцедуры

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)
	
	НастроитьUnpostИSaveDraft();
	
КонецПроцедуры


