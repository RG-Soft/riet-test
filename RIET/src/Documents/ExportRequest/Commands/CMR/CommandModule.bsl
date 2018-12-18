
&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	 	
	CustomUnionTransaction = Истина;
	
	Для Каждого Док Из ПараметрКоманды Цикл 
		
		Если Не ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Док, "CustomUnionTransaction") Тогда
			
			CustomUnionTransaction = Ложь;

			Сообщить(СокрЛП(Док) + " is not ""custom union transaction""");
			
		КонецЕсли;
	
	КонецЦикла;
		
	Если CustomUnionTransaction Тогда 
		
		УправлениеПечатьюКлиент.ВыполнитьКомандуПечати(
			"Документ.ExportRequest", 
			"CMR", 
			ПараметрКоманды,
			ПараметрыВыполненияКоманды);
			
	иначе
		
		Сообщить("CMR can be printed only for Custom Union transaction (KZ – RU – Belarus – Armenia – Kirgizia)");
		
	КонецЕсли;
		
КонецПроцедуры
	
