&НаСервере
Функция  ПолучитьПоследнееИсправление(ДокументСсылка)
	
	ПоследнееИсправление = УчетНДСПереопределяемый.ПолучитьПоследнееИсправлениеСчетаФактурыПолученного(ДокументСсылка);
	
	Возврат ПоследнееИсправление;
	
КонецФункции

&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	
	ПоследнееИсправление = ПолучитьПоследнееИсправление(ПараметрКоманды);
	
	ПараметрыФормы = Новый Структура("Основание", ПоследнееИсправление);
	ОткрытьФорму("Документ.СчетФактураВыданный.ФормаОбъекта", ПараметрыФормы, ПараметрыВыполненияКоманды.Источник, 
		ПараметрыВыполненияКоманды.Уникальность, ПараметрыВыполненияКоманды.Окно);	
	
КонецПроцедуры
