
&НаКлиенте
Процедура ЗапуститьТестирование(Команда)
	 	   	      	
	МассивСтруктурФормИУсловий = ПолучитьМассивСтруктурФормИУсловий();
	
	ЗапуститьТестированиеОбъектов(МассивСтруктурФормИУсловий);	
			
	Предупреждение("Тестирование завершено.");
	
КонецПроцедуры

&НаКлиенте
Функция ПолучитьМассивСтруктурФормИУсловий()
	
	МассивСтруктурФормИУсловий = Новый Массив;
	
	// ОБЩИЕ ФОРМЫ
	
	ДобавитьФорму(МассивСтруктурФормИУсловий, "ОбщаяФорма", "ImportExportSpecialistDesktop");
	
	ДобавитьФорму(МассивСтруктурФормИУсловий, "ОбщаяФорма", "RegistrationInImportExportTracking");
	
	
	// СПРАВОЧНИКИ
	
	// Parcels
	ДобавитьФорму(МассивСтруктурФормИУсловий, "Справочник.Parcels", "ФормаСписка");
	ДобавитьФорму(МассивСтруктурФормИУсловий, "Справочник.Parcels", "ФормаВыбора");
	ДобавитьФорму(МассивСтруктурФормИУсловий, "Справочник.Parcels", "ФормаОбъекта", "Проверен");	
	
	// Items
	ДобавитьФорму(МассивСтруктурФормИУсловий, "Справочник.СтрокиИнвойса", "ФормаСписка");
	ДобавитьФорму(МассивСтруктурФормИУсловий, "Справочник.СтрокиИнвойса", "ФормаВыбора");
	ДобавитьФорму(МассивСтруктурФормИУсловий, "Справочник.СтрокиИнвойса", "ФормаОбъекта", "Final");
	
	
	// ДОКУМЕНТЫ
	
	// Import invoices
	ДобавитьФорму(МассивСтруктурФормИУсловий, "Документ.Инвойс", "ФормаСписка");
	ДобавитьФорму(МассивСтруктурФормИУсловий, "Документ.Инвойс", "ФормаВыбора");
	ДобавитьФорму(МассивСтруктурФормИУсловий, "Документ.Инвойс", "ФормаОбъекта", "Проведен, Голд = Ложь");
	ДобавитьФорму(МассивСтруктурФормИУсловий, "Документ.Инвойс", "ФормаОбъекта", "Проведен, Голд");
          		
	// DOCs
	ДобавитьФорму(МассивСтруктурФормИУсловий, "Документ.КонсолидированныйПакетЗаявокНаПеревозку", "ФормаСписка");
	ДобавитьФорму(МассивСтруктурФормИУсловий, "Документ.КонсолидированныйПакетЗаявокНаПеревозку", "ФормаВыбора");
	ДобавитьФорму(МассивСтруктурФормИУсловий, "Документ.КонсолидированныйПакетЗаявокНаПеревозку", "Форма.ФормаОтправкиПочтовогоСообщения");
	ДобавитьФорму(МассивСтруктурФормИУсловий, "Документ.КонсолидированныйПакетЗаявокНаПеревозку", "ФормаОбъекта", "Проведен, GOLD");
	ДобавитьФорму(МассивСтруктурФормИУсловий, "Документ.КонсолидированныйПакетЗаявокНаПеревозку", "ФормаОбъекта", "Проведен, GOLD = Ложь");
	
	// Import shipments
	ДобавитьФорму(МассивСтруктурФормИУсловий, "Документ.Поставка", "ФормаСписка");
	ДобавитьФорму(МассивСтруктурФормИУсловий, "Документ.Поставка", "ФормаВыбора");
	ДобавитьФорму(МассивСтруктурФормИУсловий, "Документ.Поставка", "ФормаОбъекта", "Проведен, GOLD = Ложь");
	ДобавитьФорму(МассивСтруктурФормИУсловий, "Документ.Поставка", "ФормаОбъекта", "Проведен, GOLD");

	// ILMs
	ДобавитьФорму(МассивСтруктурФормИУсловий, "Документ.ЗакрытиеПоставки", "ФормаСписка");
	ДобавитьФорму(МассивСтруктурФормИУсловий, "Документ.ЗакрытиеПоставки", "ФормаВыбора");
	ДобавитьФорму(МассивСтруктурФормИУсловий, "Документ.ЗакрытиеПоставки", "ФормаОбъекта", "Проведен"); 
	
	// Customs files
	ДобавитьФорму(МассивСтруктурФормИУсловий, "Документ.ГТД", "ФормаСписка");
	ДобавитьФорму(МассивСтруктурФормИУсловий, "Документ.ГТД", "ФормаВыбора");
	ДобавитьФорму(МассивСтруктурФормИУсловий, "Документ.ГТД", "ФормаОбъекта", "Проведен");
	
	// ILCs
	ДобавитьФорму(МассивСтруктурФормИУсловий, "Документ.InvoiceLinesClassification", "ФормаСписка");
	ДобавитьФорму(МассивСтруктурФормИУсловий, "Документ.InvoiceLinesClassification", "ФормаВыбора");
	ДобавитьФорму(МассивСтруктурФормИУсловий, "Документ.InvoiceLinesClassification", "ФормаОбъекта", "Проведен");
	
	// Customs files light
	ДобавитьФорму(МассивСтруктурФормИУсловий, "Документ.CustomsFilesLight", "ФормаСписка");
	ДобавитьФорму(МассивСтруктурФормИУсловий, "Документ.CustomsFilesLight", "ФормаВыбора");
	ДобавитьФорму(МассивСтруктурФормИУсловий, "Документ.CustomsFilesLight", "Форма.ФормаПодбораItems", , ПолучитьСтруктуруПараметровФормыПодбораItems());
	ДобавитьФорму(МассивСтруктурФормИУсловий, "Документ.CustomsFilesLight", "ФормаОбъекта", "Проведен");
	
	// Export requests
	ДобавитьФорму(МассивСтруктурФормИУсловий, "Документ.ExportRequest", "ФормаСписка");
	ДобавитьФорму(МассивСтруктурФормИУсловий, "Документ.ExportRequest", "ФормаВыбора");
	ДобавитьФорму(МассивСтруктурФормИУсловий, "Документ.ExportRequest", "ФормаОбъекта", "ПометкаУдаления = Ложь");
	
	// Export shipments
	ДобавитьФорму(МассивСтруктурФормИУсловий, "Документ.ExportShipment", "ФормаСписка");
	ДобавитьФорму(МассивСтруктурФормИУсловий, "Документ.ExportShipment", "ФормаВыбора");
	ДобавитьФорму(МассивСтруктурФормИУсловий, "Документ.ExportShipment", "ФормаОбъекта", "ПометкаУдаления = Ложь");
	
	Возврат МассивСтруктурФормИУсловий;
	
КонецФункции

&НаСервере
Функция ПолучитьСтруктуруПараметровФормыПодбораItems()
	
	ПараметрыФормы = Новый Структура;
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ ПЕРВЫЕ 1
	               |	CustomsFilesLightItems.Ссылка,
				   |	CustomsFilesLightItems.Ссылка.ImportExport,
	               |	CustomsFilesLightItems.Ссылка.SoldTo,
	               |	CustomsFilesLightItems.Ссылка.PermanentTemporary,
	               |	CustomsFilesLightItems.Ссылка.PSAContract,
	               |	CustomsFilesLightItems.Ссылка.Shipment
	               |ИЗ
	               |	Документ.CustomsFilesLight.Items КАК CustomsFilesLightItems
	               |ГДЕ
	               |	CustomsFilesLightItems.Ссылка.Проведен
	               |	И CustomsFilesLightItems.Item <> ЗНАЧЕНИЕ(Справочник.СтрокиИнвойса.ПустаяСсылка)";
	
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда 
		ПараметрыФормы.Вставить("TypeOfTransaction", Перечисления.TypesOfCustomsFileLightTransaction.CustomsFileLight);
		ПараметрыФормы.Вставить("ImportExport", Выборка.ImportExport);
		ПараметрыФормы.Вставить("ParentCompany", Выборка.SoldTo);
		ПараметрыФормы.Вставить("PermanentTemporary", Выборка.PermanentTemporary);
		ПараметрыФормы.Вставить("PSAContract", Выборка.PSAContract);
		ПараметрыФормы.Вставить("Shipment", Выборка.Shipment);
		ПараметрыФормы.Вставить("CurrentCustomsFileLight", Выборка.Ссылка);
		ПараметрыФормы.Вставить("CurrentItems", Новый Массив);
	КонецЕсли;
	
	Возврат ПараметрыФормы;
	
КонецФункции

&НаКлиенте
Процедура ДобавитьФорму(Массив, ИмяОбъекта, ИмяОткрываемойФормы, Условие=Неопределено, СтруктураПараметров=Неопределено)
	
	Массив.Добавить(Новый Структура("ИмяОбъекта, ИмяФормы, Условие, СтруктураПараметров", 
				              ИмяОбъекта, ИмяОткрываемойФормы, Условие, ?(СтруктураПараметров = Неопределено, Новый Структура(), СтруктураПараметров)));
	
КонецПроцедуры

&НаКлиенте
Процедура ЗапуститьТестированиеОбъектов(МассивСтруктурФормИУсловий)
	
	Для Каждого СтруктураФормаИУсловие из МассивСтруктурФормИУсловий Цикл 
		
		ИмяОбъекта = СтруктураФормаИУсловие.ИмяОбъекта;
		ИмяОткрываемойФормы = ИмяОбъекта + "." + СтруктураФормаИУсловие.ИмяФормы;
		Условие = СтруктураФормаИУсловие.Условие;
		ПараметрыФормы = СтруктураФормаИУсловие.СтруктураПараметров;
		      		
		Если Условие = Неопределено Тогда 
			
			Форма = ОткрытьФорму(ИмяОткрываемойФормы, ПараметрыФормы);
			Форма.Закрыть();
			
			Продолжить;
			
		КонецЕсли;
		
		МассивКлючей = ПолучитьМассивКлючей(ИмяОбъекта, Условие);
		Для Каждого Ключ из МассивКлючей Цикл
			
			ПараметрыФормы.вставить("Ключ", Ключ);
			
			Форма = ОткрытьФорму(ИмяОткрываемойФормы, ПараметрыФормы);
			Форма.Закрыть();
			
		КонецЦикла;			
		
	КонецЦикла;
	           		
КонецПроцедуры

&НаСервере
Функция ПолучитьМассивКлючей(ИмяОбъекта, Условия)
	
	ТекстУсловия = "";
	МассивУсловий = СтроковыеФункцииКлиентСервер.РазложитьСтрокуВМассивПодстрок(Условия, ",");
	
	Для Каждого Условие из МассивУсловий Цикл 
		ТекстУсловия = ТекстУсловия + ?(ТекстУсловия = "" , "", " И ") + "Таблица." + СокрЛП(Условие);
	КонецЦикла; 
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ ПЕРВЫЕ 3
	|	Таблица.Ссылка
	|ИЗ
	|	"+ИмяОбъекта+" КАК Таблица
	|ГДЕ "+ТекстУсловия+"
	|";
		
	Возврат Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Ссылка");
	
КонецФункции

