
&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	НастроитьВидимостьЭлементов();

КонецПроцедуры

&НаКлиенте
Процедура НастроитьВидимостьЭлементов()
	
	Если Не ЗначениеЗаполнено(Объект.DomesticInternational) Тогда 
		Возврат;
	КонецЕсли;
	
	Элементы.ГруппаInternational.Видимость = (Объект.DomesticInternational = ПредопределенноеЗначение("Перечисление.DomesticInternational.International"));
	Элементы.ГруппаDomestic.Видимость = (Объект.DomesticInternational = ПредопределенноеЗначение("Перечисление.DomesticInternational.Domestic"));
	Элементы.ГруппаIntPOItem.Видимость = (Объект.DomesticInternational = ПредопределенноеЗначение("Перечисление.DomesticInternational.International"));
	Элементы.Balance.Видимость = (Объект.DomesticInternational = ПредопределенноеЗначение("Перечисление.DomesticInternational.Domestic"));
    Элементы.ГруппаItemsCompleted.Видимость = (Объект.DomesticInternational = ПредопределенноеЗначение("Перечисление.DomesticInternational.Domestic"));
    	        
КонецПроцедуры

&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	
	РГСофт.ЗаполнитьModification(ТекущийОбъект);

КонецПроцедуры

&НаКлиенте
Процедура FillFromCatalog(Команда)
	
	Если НЕ ЗначениеЗаполнено(Объект.Каталог) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("'Catalog' is empty!",
			, "Каталог", "Объект");
		Возврат;
	КонецЕсли;

	СтруктураРеквизитовКаталога = ПолучитьСтруктуруРеквизитовКаталога(Объект.Каталог);
	
	Если ЗначениеЗаполнено(Объект.Наименование) 
		ИЛИ ЗначениеЗаполнено(Объект.ItemDescription)
		ИЛИ ЗначениеЗаполнено(Объект.DescriptionRus)
		ИЛИ ЗначениеЗаполнено(Объект.GrossWeightKG) Тогда 
		Оповещение = Новый ОписаниеОповещения("ПослеЗакрытияВопросаЗаполнениеПоКаталогу", ЭтаФорма, СтруктураРеквизитовКаталога);
		ПоказатьВопрос(Оповещение, "Перезаполнить поля по каталогу?", РежимДиалогаВопрос.ДаНет,,, "Заполнение по каталогу");
	иначе
		ЗаполненитьПоКаталогу(СтруктураРеквизитовКаталога);
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ПослеЗакрытияВопросаЗаполнениеПоКаталогу(Результат, Параметры) Экспорт
	
	Если Результат = КодВозвратаДиалога.Нет Тогда
        Возврат;
    КонецЕсли;

    ЗаполненитьПоКаталогу(Параметры);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполненитьПоКаталогу(СтруктураРеквизитовКаталога) Экспорт
	
	Объект.Наименование = СтруктураРеквизитовКаталога.PartNo;
	Объект.DescriptionRus = СтруктураРеквизитовКаталога.DescriptionRus;
	Объект.ItemDescription = СтруктураРеквизитовКаталога.DescriptionEng;
	Если ЗначениеЗаполнено(СтруктураРеквизитовКаталога.NetWeight) Тогда 
		Объект.GrossWeightKG = СтруктураРеквизитовКаталога.NetWeight;
	КонецЕсли;

КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьСтруктуруРеквизитовКаталога(Catalog)
	
	Возврат Справочники.СтрокиИнвойса.ПолучитьСтруктуруРеквизитовКаталога(Catalog);
	
КонецФункции  

&НаКлиенте
Процедура ItemНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	НачалоВыбораItem(Элемент);
	                                   	
КонецПроцедуры

&НаКлиенте
Процедура НачалоВыбораItem(Элемент)
	 		
	Отказ = Ложь;
	
	Если НЕ ЗначениеЗаполнено(Объект.Наименование) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"""Part number"" is empty!",
			, "Наименование", "Объект", Отказ);
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Объект.DomesticInternational) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"""Dom/Int"" is empty!",
			, "DomesticInternational", "Объект", Отказ);
	КонецЕсли;
		
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
		
	#Если ВебКлиент Тогда
	АктивноеОкно = АктивноеОкно();
	Если АктивноеОкно <> Неопределено Тогда
		Если АктивноеОкно.Содержимое.Количество() > 0 Тогда
			Если АктивноеОкно.Содержимое[0].ИмяФормы = "Справочник.СтрокиИнвойса.Форма.ФормаВыбора" Тогда
				АктивноеОкно.Активизировать();
				Возврат;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	#КонецЕсли
	
	СтруктураПараметров = Новый Структура;
	
	СтруктураНастройки = Новый Структура;
	СтруктураНастройки.Вставить("Имя", "ВыборИзManualItem");
	
	СтруктураНастройки.Вставить("КодПоИнвойсу", Объект.Наименование);
	СтруктураНастройки.Вставить("POLine", Объект.POLine);
	СтруктураНастройки.Вставить("DomesticInternational", Объект.DomesticInternational);   
	
	Если Объект.DomesticInternational = ПредопределенноеЗначение("Перечисление.DomesticInternational.Domestic") Тогда
		
		Если ЗначениеЗаполнено(Объект.Владелец) Тогда
			СтруктураНастройки.Вставить("ProjectMobilization", Объект.Владелец);
		КонецЕсли;
		Если ЗначениеЗаполнено(Объект.PickUpWarehouse) Тогда
			СтруктураНастройки.Вставить("PickUpWarehouse", Объект.PickUpWarehouse);
		КонецЕсли;
		Если ЗначениеЗаполнено(Объект.DeliverTo) Тогда
			СтруктураНастройки.Вставить("DeliverTo", Объект.DeliverTo);
		КонецЕсли;
		
		СтруктураПараметров.Вставить("МножественныйВыбор", Истина);
		
	КонецЕсли;
	
	СтруктураПараметров.Вставить("СтруктураНастройки", СтруктураНастройки);
		
	ОткрытьФорму("Справочник.СтрокиИнвойса.ФормаВыбора", СтруктураПараметров, Элемент);
	                	
КонецПроцедуры

&НаКлиенте
Процедура POLineНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
		Если ЗначениеЗаполнено(Объект.Наименование) Тогда
		
		СтандартнаяОбработка = Ложь;
		
		#Если ВебКлиент Тогда
			АктивноеОкно = АктивноеОкно();
			Если АктивноеОкно <> Неопределено Тогда
				Если АктивноеОкно.Содержимое.Количество() > 0 Тогда
					Если АктивноеОкно.Содержимое[0].ИмяФормы = "Справочник.СтрокиЗаявкиНаЗакупку.Форма.ФормаВыбора" Тогда
						АктивноеОкно.Активизировать();
						Возврат;
					КонецЕсли;
				КонецЕсли;
			КонецЕсли;
		#КонецЕсли
		
		СтруктураНастройки = Новый Структура;
		СтруктураНастройки.Вставить("Имя", "ВыборИзManualItem");
		
		СтруктураНастройки.Вставить("PartNo", Объект.Наименование);
		
		СтруктураПараметров = Новый Структура;
		СтруктураПараметров.Вставить("СтруктураНастройки", СтруктураНастройки);
		
		ОткрытьФорму("Справочник.СтрокиЗаявкиНаЗакупку.ФормаВыбора", СтруктураПараметров, Элемент);
		
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура DomesticInternationalПриИзменении(Элемент)
	
	НастроитьВидимостьЭлементов();
	
	Объект.PickUpWarehouse = Неопределено;
	Объект.DeliverTo = Неопределено;
	
КонецПроцедуры

&НаКлиенте
Процедура POLineПриИзменении(Элемент)
	
	POLineПриИзмененииНаСервере();
	
КонецПроцедуры

&НаСервере
Процедура POLineПриИзмененииНаСервере()
	
	Объект.Наименование = Объект.POLine.КодПоставщика;
	Объект.ItemDescription = Объект.POLine.ОписаниеНоменклатуры;
	Объект.DescriptionRus = Объект.POLine.ОписаниеНоменклатуры;
	Объект.Каталог = Объект.POLine.Каталог;
	Объект.RDD = Объект.POLine.SupplierPromisedDate;
	Объект.Qty = Объект.POLine.Количество;
	Цена = Объект.POLine.Цена;
	Валюта = Объект.POLine.Валюта;
	Если Валюта <> Справочники.Валюты.НайтиПоНаименованию("USD") Тогда
		Цена = LocalDistributionForNonLawsonСервер.ПолучитьCostsSumSLBUSD(Цена, Валюта, Объект.POLine.Владелец.ДатаЗаявкиНаЗакупку);
	КонецЕсли;
	Объект.ItemValue = Цена;
	Объект.Supplier = Объект.POLine.Владелец.Поставщик;
    Объект.SupplierAvailability = Объект.POLine.SupplierPromisedDate;
	
КонецПроцедуры

// VALUES

&НаКлиенте
Процедура QtyПриИзменении(Элемент)
	
	Объект.TotalGrossWeightKG = Объект.GrossWeightKG * Объект.Qty; 
	Объект.TotalValue = Объект.ItemValue * Объект.Qty; 
	Объект.BalanceQty = Объект.Qty - Объект.Items.Итог("Qty");
	
КонецПроцедуры

&НаКлиенте
Процедура GrossWeightKGПриИзменении(Элемент)
	
	Объект.TotalGrossWeightKG = Объект.GrossWeightKG * Объект.Qty; 
	Объект.BalanceTotalGrossWeightKG = Объект.TotalGrossWeightKG - Объект.Items.Итог("TotalGrossWeightKG");
	
КонецПроцедуры

&НаКлиенте
Процедура ValueПриИзменении(Элемент)
	
	Объект.TotalValue = Объект.ItemValue * Объект.Qty;
	
КонецПроцедуры  

&НаКлиенте
Процедура TotalGrossWeightKGПриИзменении(Элемент)
	
	Объект.GrossWeightKG = ?(Объект.Qty = 0, 0, Объект.TotalGrossWeightKG / Объект.Qty); 
	Объект.BalanceTotalGrossWeightKG = Объект.TotalGrossWeightKG - Объект.Items.Итог("TotalGrossWeightKG");
	
КонецПроцедуры

&НаКлиенте
Процедура TotalValueПриИзменении(Элемент)
	
	Объект.ItemValue = ?(Объект.Qty = 0, 0, Объект.TotalValue / Объект.Qty); 
	
КонецПроцедуры

&НаКлиенте
Процедура ItemsПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа, Параметр)
	
	Отказ = Истина;
	
	НачалоВыбораItem(Элемент);
	
КонецПроцедуры

&НаКлиенте
Процедура RefreshValues(Команда)
	
	ОбновитьЗначенияItem();
	
КонецПроцедуры

&НаКлиенте
Процедура ItemsОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	Для Каждого ЭлементМассива из ВыбранноеЗначение Цикл 
		
		СтрокаItems = Объект.Items.Добавить();
		СтрокаItems.Item = ЭлементМассива;
		
	КонецЦикла;
	
	ОбновитьЗначенияItem();
	
КонецПроцедуры

&НаСервере
Процедура ОбновитьЗначенияItem()
	
	СтруктураОтбораItem = Новый Структура("Item");
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("МассивItems", объект.Items.Выгрузить().ВыгрузитьКолонку("Item"));
	
	Запрос.Текст = "ВЫБРАТЬ
	               |	СУММА(ParcelsДетали.Qty) КАК Qty,
	               |	СУММА(ParcelsДетали.GrossWeightKG) КАК TotalGrossWeightKG,
	               |	ParcelsДетали.СтрокаИнвойса КАК Item
	               |ИЗ
	               |	Справочник.Parcels.Детали КАК ParcelsДетали
	               |ГДЕ
	               |	ParcelsДетали.СтрокаИнвойса В(&МассивItems)
	               |
	               |СГРУППИРОВАТЬ ПО
	               |	ParcelsДетали.СтрокаИнвойса";
	
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		
		СтруктураОтбораItem.Item = Выборка.Item;
		МассивСтрок = Объект.Items.НайтиСтроки(СтруктураОтбораItem);
		
		Для Каждого СтрокаМассива из МассивСтрок Цикл
			
			Если СтрокаМассива.Qty <> Выборка.Qty Тогда
				СтрокаМассива.Qty = Выборка.Qty;
				ЭтаФорма.Модифицированность = Истина;
			КонецЕсли;
			
			Если СтрокаМассива.TotalGrossWeightKG <> Выборка.TotalGrossWeightKG Тогда
				СтрокаМассива.TotalGrossWeightKG = Выборка.TotalGrossWeightKG;
				ЭтаФорма.Модифицированность = Истина;
			КонецЕсли;

		КонецЦикла;
		
	КонецЦикла;  	
	
	BalanceQty = Объект.Qty - Объект.Items.Итог("Qty");
	Если Объект.BalanceQty <> BalanceQty Тогда
		Объект.BalanceQty = BalanceQty;
		ЭтаФорма.Модифицированность = Истина;
	КонецЕсли;
	
	BalanceTotalGrossWeightKG = Объект.TotalGrossWeightKG - Объект.Items.Итог("TotalGrossWeightKG");
	Если Объект.BalanceTotalGrossWeightKG <> BalanceTotalGrossWeightKG Тогда
		Объект.BalanceTotalGrossWeightKG = BalanceTotalGrossWeightKG;
		ЭтаФорма.Модифицированность = Истина;
	КонецЕсли;

КонецПроцедуры


