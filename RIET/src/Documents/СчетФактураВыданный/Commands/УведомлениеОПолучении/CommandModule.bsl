
&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	
	//Если УправлениеПечатьюКлиент.ПроверитьДокументыПроведены(ПараметрКоманды, ПараметрыВыполненияКоманды.Источник) Тогда
	Если Не ПараметрыВыполненияКоманды.Источник.Модифицированность	Тогда
		УправлениеПечатьюКлиент.ВыполнитьКомандуПечати("Документ.СчетФактураВыданный",
			"УведомлениеОПолучении",
			ПараметрКоманды,
			ПараметрыВыполненияКоманды,
			Неопределено);
		
	КонецЕсли;	
	//КонецЕсли;
	
КонецПроцедуры

