
/////////////////////////////////////////////////////////////////////////////////////
// ОБЩИЕ МЕХАНИЗМЫ






/////////////////////////////////////////////////////////////////////////////////////
// ПЕРЕНЕСТИ В ДРУГИЕ МОДУЛИ ИЛИ УДАЛИТЬ

// ПЕРЕНЕСТИ В IMPORTEXPORTКЛИЕНТСЕРВЕР
Функция ПолучитьНомерPOДляПоиска(Знач НомерPO) Экспорт
	
	 НомерPO = СтрЗаменить(НомерPO, "-0-SWPS", "");
	 Возврат НомерPO;
	
КонецФункции
 
// УДАЛИТЬ. ТАКАЯ ФУНКЦИЯ ЕСТЬ В РГСОФТКЛИЕНТСЕРВЕР
Функция ВыгрузитьКолонкуКоллекции(ЭлементФормыДанныеФормыКоллекция, ИмяКолонки) Экспорт
	
	МассивДанных = Новый Массив;
	Для Каждого Стр из ЭлементФормыДанныеФормыКоллекция Цикл 
		МассивДанных.Добавить(Стр[ИмяКолонки]);
	КонецЦикла;
	
	Возврат МассивДанных;
	   
КонецФункции


/////////////////////////////////////////////////////////////////////////////////////
// SERVICES (ВЫДЕЛИТЬ В ОТДЕЛЬНЫЙ МОДУЛЬ)

Процедура ОбновитьПодвалServices(DocumentBase, Base, Markup, Sum, Discount, GrandTotal) Экспорт
	
	Если ЗначениеЗаполнено(DocumentBase) Тогда
		
		СтруктураИтогов = CustomsСервер.ПолучитьСтруктуруИтоговServices(DocumentBase);
		Base = СтруктураИтогов.Base;
		Markup = СтруктураИтогов.Markup;
		Sum = СтруктураИтогов.Sum;
		Discount = СтруктураИтогов.Discount;
		GrandTotal = СтруктураИтогов.GrandTotal;
		
	Иначе
		
		Base = 0;
		Markup = 0;
		Sum = 0;
		Discount = 0;
		GrandTotal = 0;
		
	КонецЕсли;  
	
КонецПроцедуры


