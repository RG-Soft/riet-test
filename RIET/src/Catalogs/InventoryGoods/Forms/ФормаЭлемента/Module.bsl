
&НаКлиенте
Процедура StandardUOMНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
    СтандартнаяОбработка = Ложь;	
	
	ПараметрыФормы = Новый Структура;
	
	ПараметрыОтбора = Новый Структура;
	ПараметрыОтбора.Вставить("Standard", Истина);
	
	Если ПараметрыОтбора.Количество() Тогда
		ПараметрыФормы.Вставить("Отбор", ПараметрыОтбора);
	КонецЕсли;
	
	ОткрытьФорму("Справочник.UOMs.ФормаВыбора",ПараметрыФормы,Элемент);	
	
КонецПроцедуры


&НаКлиенте
Процедура ПодборНаименования(Команда)
	
	СписокНаименований = ПолучитьСписокНаСервере(Объект.Ссылка);
	Если СписокНаименований.Количество() > 0  Тогда
		Элемент = СписокНаименований.ВыбратьЭлемент("Выберите наименование:");
		Если Элемент <> Неопределено Тогда
		
			Объект.DescriptionRus = Элемент.Значение;
		
		КонецЕсли; 
	Иначе		
		Сообщить("Переводов не найдено");
	КонецЕсли; 
	
КонецПроцедуры

&НаСервере
Функция ПолучитьСписокНаСервере(Каталог)
	
	Запрос = Новый Запрос("ВЫБРАТЬ РАЗЛИЧНЫЕ
	                      |	InvoiceLinesClassificationClassification.Translation
	                      |ИЗ
	                      |	Документ.InvoiceLinesClassification.Classification КАК InvoiceLinesClassificationClassification
	                      |ГДЕ
	                      |	InvoiceLinesClassificationClassification.InvoiceLine.Каталог.Код ПОДОБНО &Код + ""%""
	                      |
	                      |ОБЪЕДИНИТЬ
	                      |
	                      |ВЫБРАТЬ РАЗЛИЧНЫЕ
	                      |	НоменклатураИмпорт.НаименованиеРусское
	                      |ИЗ
	                      |	Справочник.НоменклатураИмпорт КАК НоменклатураИмпорт
	                      |ГДЕ
	                      |	НоменклатураИмпорт.Код ПОДОБНО &Код + ""%""");	
	Запрос.УстановитьПараметр("Код", Каталог.Код);
	
	Список = Новый СписокЗначений;
	Список.ЗагрузитьЗначения(Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Translation"));
	
	Возврат Список;

КонецФункции // ПолучитьСписокНаСервере()
 
