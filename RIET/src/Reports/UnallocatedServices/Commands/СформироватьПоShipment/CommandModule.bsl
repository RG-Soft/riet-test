
&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
		
	СтруктураОтбора = Новый Структура;
	СтруктураОтбора.Вставить("DocumentBase", ПараметрКоманды);
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("Отбор", СтруктураОтбора);
	ПараметрыФормы.Вставить("СформироватьПриОткрытии", Истина);	
		
	ОткрытьФорму("Отчет.UnallocatedServices.Форма", ПараметрыФормы, ПараметрыВыполненияКоманды.Источник, ПараметрыВыполненияКоманды.Уникальность, ПараметрыВыполненияКоманды.Окно);
	
КонецПроцедуры
