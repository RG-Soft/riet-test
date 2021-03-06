////////////////////////////////////////////////////////////////////////////////
// ЭлектронныеДокументыКлиент: механизм обмена электронными документами.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// ПРОГРАММНЫЙ ИНТЕРФЕЙС

////////////////////////////////////////////////////////////////////////////////
// Работа с электронными документами

// Процедура открывает форму администрирования обмена электронными документами.
//
// Параметры:
//  ПараметрКоманды - ссылкаНаОбъект - ссылка на объект ИБ, электронные документы которого надо отправить,
//  ПараметрыОткрытия - структура, дополнительные параметры просмотра.
//
Процедура ОткрытьФормуОбменаЭлектроннымиДокументами(ПараметрКоманды, ПараметрыВыполненияКоманды) Экспорт
	
	ИмяФормы = "ОбменЭлектроннымиДокументами";
	
	ПараметрыФормы = Новый Структура("ТекущийРаздел", ИмяФормы);
	
	#Если ВебКлиент Тогда
	ОкноОткрытияПанели = ПараметрыВыполненияКоманды.Окно;
	#Иначе
	ОкноОткрытияПанели = ПараметрыВыполненияКоманды.Источник;
	#КонецЕсли

	ОткрытьФорму(
		"Обработка.ПанельАдминистрированияЭД.Форма.ОбменЭлектроннымиДокументами",
		ПараметрыФормы,
		ПараметрыВыполненияКоманды.Источник,
		ПараметрыВыполненияКоманды.Уникальность,
		ОкноОткрытияПанели);
	
КонецПроцедуры

// Открывает форму со списком электронных документов для данного владельца.
//
// Параметры:
//  СсылкаНаОбъект - ссылка на объект ИБ, электронные документы которого надо увидеть.
//  ПараметрыОткрытия - структура, дополнительные параметры просмотра списка электронных документов.
//
Процедура ОткрытьСписокЭД(СсылкаНаОбъект, ПараметрыОткрытия = Неопределено) Экспорт
	
	Если НЕ ЭлектронныеДокументыСлужебныйВызовСервера.ЕстьПравоЧтенияЭД() Тогда
		Возврат;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(СсылкаНаОбъект) Тогда
		Возврат;
	КонецЕсли;
	
	ПараметрыЭД = Неопределено;
	ОткрытьФормуСоглашения = Ложь;
	ПроверятьДляСоглашения = (ПараметрыОткрытия = Неопределено);
	Если ЭлектронныеДокументыСлужебныйВызовСервера.МожноОткрытьВФормеДереваЭД(СсылкаНаОбъект,
		ПроверятьДляСоглашения, ОткрытьФормуСоглашения, ПараметрыЭД) Тогда
		
		ОткрытьДеревоЭД(СсылкаНаОбъект, ПараметрыОткрытия, Ложь);
	ИначеЕсли ОткрытьФормуСоглашения Тогда
		ПараметрыФормы = Новый Структура;
		ЗначенияЗаполнения = Новый Структура;
		
		Если ПараметрыЭД.Свойство("НастройкаЭДО") Тогда
			ПараметрыФормы.Вставить("Ключ", ПараметрыЭД.НастройкаЭДО);
		КонецЕсли;
		ЗначенияЗаполнения.Вставить("Контрагент", ПараметрыЭД.Контрагент);
		ЗначенияЗаполнения.Вставить("Организация", ПараметрыЭД.Организация);
		ПараметрыФормы.Вставить("ЗначенияЗаполнения", ЗначенияЗаполнения);
		ОткрытьФорму("Справочник.СоглашенияОбИспользованииЭД.Форма.ФормаЭлемента", ПараметрыФормы, , СсылкаНаОбъект.УникальныйИдентификатор());
		
	Иначе
		
		ПараметрыФормы = Новый Структура("ОбъектОтбора", СсылкаНаОбъект);
		Если ПараметрыОткрытия = Неопределено Тогда
			ОткрытьФорму("Обработка.ЭлектронныеДокументы.Форма.СписокЭД", ПараметрыФормы);
		Иначе
			Окно = Неопределено;
			Если ТипЗнч(ПараметрыОткрытия) = Тип("ПараметрыВыполненияКоманды") Тогда
				Окно = ПараметрыОткрытия.Окно;
			КонецЕсли;
			ОткрытьФорму("Обработка.ЭлектронныеДокументы.Форма.СписокЭД", ПараметрыФормы,
			ПараметрыОткрытия.Источник, ПараметрыОткрытия.Уникальность, Окно);
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

// Перезаполняет документ ИБ на основании актуального ЭД
//
// Параметры:
//  ПараметрКоманды - ссылка на объект
//  Источник - управляемая форма
//
Процедура ПерезаполнитьДокумент(ПараметрКоманды, Источник = Неопределено, СопоставлениеУжеВыполнено = Ложь, ЭД = Неопределено) Экспорт
	
	Если НЕ ЭлектронныеДокументыСлужебныйВызовСервера.ЕстьПравоОбработкиЭД() Тогда
		ЭлектронныеДокументыСлужебныйКлиент.СообщитьПользователюОНарушенииПравДоступа();
		Возврат;
	КонецЕсли;
	
	МассивСсылок = ЭлектронныеДокументыСлужебныйКлиент.ПолучитьМассивПараметров(ПараметрКоманды);
	Если МассивСсылок = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	МассивПроведенныхДокументов = ЭлектронныеДокументыСлужебныйВызовСервера.МассивПроведенныхДокументов(МассивСсылок);
	Шаблон = ВернутьСтр("ru = 'Обработка документа %1.
						|Операция возможна только для непроведенных документов!'");
	Для Каждого Документ ИЗ МассивПроведенныхДокументов Цикл
		ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(Шаблон, Документ);
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстОшибки);
	КонецЦикла;
	
	МассивСсылок = ОбщегоНазначенияКлиентСервер.СократитьМассив(МассивСсылок, МассивПроведенныхДокументов);
	
	Если МассивСсылок.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	СопоставлятьНоменклатуруПередЗаполнениемДокумента = Ложь;
	ЭлектронныеДокументыКлиентПереопределяемый.СопоставлятьНоменклатуруПередЗаполнениемДокумента(
												СопоставлятьНоменклатуруПередЗаполнениемДокумента);
	
	Если ЗначениеЗаполнено(ЭД) Тогда
		СоответствиеВладельцевИЭД = Новый Соответствие;
		СоответствиеВладельцевИЭД.Вставить(ПараметрКоманды, ЭД);
	Иначе
		СоответствиеВладельцевИЭД = ЭлектронныеДокументыСлужебныйВызовСервера.ПолучитьСоответствиеВладельцевИЭД(
																									МассивСсылок);
	КонецЕсли;
	
	Если СоответствиеВладельцевИЭД.Количество() = 0 Тогда
		Для Каждого ТекущийДокумент Из МассивСсылок Цикл
			Шаблон = ВернутьСтр("ru = 'Электронный документ для %1 не найден'");
			ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(Шаблон, ТекущийДокумент);
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстОшибки);
		КонецЦикла;
		Возврат;
	КонецЕсли;
	
	МассивИзмененныхВладельцев = Новый Массив;
	
	// Команда "ПерезаполнитьДокумент" имеет режим использования команды - Одиночный.
	СсылкаНаЭД = СоответствиеВладельцевИЭД.Получить(ПараметрКоманды);
	
	Если Не ЗначениеЗаполнено(СсылкаНаЭД) Тогда
		Возврат;
	КонецЕсли;
	
	ОбъектМетаданных = "";
	ДокументЗагружен = Ложь;
	
	Если СопоставлятьНоменклатуруПередЗаполнениемДокумента И Не СопоставлениеУжеВыполнено Тогда
		СтруктураПараметров = ЭлектронныеДокументыСлужебныйВызовСервера.ПолучитьПараметрыФормыСопоставленияНоменклатуры(
			СсылкаНаЭД);
		Если ЗначениеЗаполнено(СтруктураПараметров) Тогда
			ОткрытьФорму(СтруктураПараметров.ИмяФормы, СтруктураПараметров.ПараметрыОткрытияФормы, Источник);
			Возврат;
		КонецЕсли;
	КонецЕсли;
	
	ЭлектронныеДокументыСлужебныйВызовСервера.ПерезаполнитьДокументыИБПоЭД(
		ПараметрКоманды,
		СсылкаНаЭД,
		ОбъектМетаданных,
		ДокументЗагружен);
	
	Если ДокументЗагружен Тогда
			
		МассивИзмененныхВладельцев.Добавить(ПараметрКоманды);
		
		Оповестить("ОбновитьСостояниеЭД");
		Оповестить("ОбновитьДокументИБПослеЗаполнения", МассивИзмененныхВладельцев);
		
		
		Если НЕ СопоставлятьНоменклатуруПередЗаполнениемДокумента Тогда
			
			СтруктураПараметров = ЭлектронныеДокументыСлужебныйВызовСервера.ПолучитьПараметрыФормыСопоставленияНоменклатуры(
			СсылкаНаЭД);
			Если ЗначениеЗаполнено(СтруктураПараметров) Тогда
				
				ДопПараметры = Новый Структура;
				ДопПараметры.Вставить("ОбъектМетаданных", ОбъектМетаданных);
				ДопПараметры.Вставить("КлючФормы", ПараметрКоманды);
				
				Обработчик = Новый ОписаниеОповещения("ЗаполитьДокументПоЭД", ЭтотОбъект, ДопПараметры);
				Режим = РежимОткрытияОкнаФормы.БлокироватьОкноВладельца;
				
				ОткрытьФорму(СтруктураПараметров.ИмяФормы, СтруктураПараметров.ПараметрыОткрытияФормы,,,,,Обработчик, Режим);
				
			КонецЕсли;
				
		КонецЕсли;
	КонецЕсли;
		
	Если МассивИзмененныхВладельцев.Количество() > 0 Тогда
		
		ТекстСостоянияВывод = ВернутьСтр("ru = 'Документ перезаполнен.'");
		ТекстЗаголовка = ВернутьСтр("ru = 'Обмен электронными документами'");
		ПоказатьОповещениеПользователя(ТекстЗаголовка, , ТекстСостоянияВывод);
		
	КонецЕсли;

КонецПроцедуры

Процедура ЗаполитьДокументПоЭД(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ОбъектМетаданных = ДополнительныеПараметры.ОбъектМетаданных;
	КлючФормы = ДополнительныеПараметры.КлючФормы;
	
	ФормаДокумента = ПолучитьФорму(ОбъектМетаданных + ".ФормаОбъекта", Новый Структура("Ключ", КлючФормы));
	
	Если ТипЗнч(ФормаДокумента) = Тип("УправляемаяФорма") Тогда
		ДанныеФормы = ФормаДокумента.Объект;
	Иначе
		ДанныеФормы = ФормаДокумента.ДокументОбъект;
	КонецЕсли;
	
	ЭлектронныеДокументыСлужебныйВызовСервера.ЗаполнитьИсточник(ДанныеФормы, Результат);
	
	Если ТипЗнч(ФормаДокумента) = Тип("УправляемаяФорма") Тогда
		КопироватьДанныеФормы(ДанныеФормы, ФормаДокумента.Объект);
	Иначе
		ФормаДокумента.ДокументОбъект = ДанныеФормы;
	КонецЕсли;
	
	ФормаДокумента.Открыть();
	ФормаДокумента.Модифицированность = Истина;
	
КонецПроцедуры

// Открывает актуальный ЭД по документу ИБ
//
// Параметры:
//  ПараметрКоманды - ссылка на документ ИБ;
//  Источник - управляемая форма;
//  ПараметрыОткрытия - структура, дополнительные параметры просмотра.
//
Процедура ОткрытьАктуальныйЭД(ПараметрКоманды, Источник = Неопределено, ПараметрыОткрытия = Неопределено) Экспорт
	
	ОчиститьСообщения();
	
	#Если ТолстыйКлиентОбычноеПриложение Тогда
		Если НЕ ЭлектронныеДокументыСлужебныйВызовСервера.ЕстьПравоЧтенияЭД() Тогда
			Возврат;
		КонецЕсли;
	#КонецЕсли
	
	МассивСсылок = ЭлектронныеДокументыСлужебныйКлиент.ПолучитьМассивПараметров(ПараметрКоманды);
	Если МассивСсылок = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	СоответствиеВладельцевИЭД = ЭлектронныеДокументыСлужебныйВызовСервера.ПолучитьСоответствиеВладельцевИЭД(МассивСсылок);
	Для Каждого ТекЭл Из МассивСсылок Цикл
		
		СсылкаНаЭД = СоответствиеВладельцевИЭД.Получить(ТекЭл);
		Если ЗначениеЗаполнено(СсылкаНаЭД) Тогда
			Если ТипЗнч(ПараметрыОткрытия) = Тип("ПараметрыВыполненияКоманды") Тогда
				
				ЭлектронныеДокументыСлужебныйКлиент.ОткрытьЭДДляПросмотра(СсылкаНаЭД,
																		  ПараметрыОткрытия,
																		  ПараметрыОткрытия.Источник);
			Иначе
				ЭлектронныеДокументыСлужебныйКлиент.ОткрытьЭДДляПросмотра(СсылкаНаЭД, , Источник);
			КонецЕсли;
			
		Иначе
			ТекстШаблона = ВернутьСтр("ru = '%1. Актуальный электронный документ не найден!'");
			ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ТекстШаблона, ТекЭл);
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

// Открывает форму с деревом электронных документов для данного владельца.
//
// Параметры:
//  СсылкаНаОбъект - ссылка на объект ИБ, электронные документы которого надо увидеть,
//  ПараметрыОткрытия - структура, дополнительные параметры просмотра дерева электронных документов.
//  ПроверятьСоглашение - Булево - используется для исключения лишнего серверного вызова,
//    при вызове данной процедуры из процедуры ОткрытьСписокЭД(...), т.к. данная проверка там уже выполнялась.
//
Процедура ОткрытьДеревоЭД(СсылкаНаОбъект, ПараметрыОткрытия = Неопределено, ПроверятьСоглашение = Истина) Экспорт
	
	Если Не ЭлектронныеДокументыСлужебныйВызовСервера.ЕстьПравоЧтенияЭД() Тогда
		Возврат;
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(СсылкаНаОбъект) Тогда
		Возврат;
	КонецЕсли;
	
	ПараметрыЭД = Неопределено;
	Если ПроверятьСоглашение
		И Не ЭлектронныеДокументыСлужебныйВызовСервера.ОпределитьДействующуюНастройкуЭДО(СсылкаНаОбъект, ПараметрыЭД) Тогда
		
		ПараметрыФормы = Новый Структура;
		ЗначенияЗаполнения = Новый Структура;
		
		Если ПараметрыЭД.Свойство("НастройкаЭДО") Тогда
			ПараметрыФормы.Вставить("Ключ", ПараметрыЭД.НастройкаЭДО);
		КонецЕсли;
		ЗначенияЗаполнения.Вставить("Контрагент", ПараметрыЭД.Контрагент);
		ЗначенияЗаполнения.Вставить("Организация", ПараметрыЭД.Организация);
		ПараметрыФормы.Вставить("ЗначенияЗаполнения", ЗначенияЗаполнения);
		ОткрытьФорму("Справочник.СоглашенияОбИспользованииЭД.Форма.ФормаЭлемента", ПараметрыФормы, , СсылкаНаОбъект.УникальныйИдентификатор());
		
	Иначе
		
		ПараметрыФормы = Новый Структура("ОбъектОтбора", СсылкаНаОбъект);
		Если ПараметрыОткрытия = Неопределено Тогда
			ОткрытьФорму("Обработка.ЭлектронныеДокументы.Форма.ДеревоЭД", ПараметрыФормы, , СсылкаНаОбъект.УникальныйИдентификатор());
		Иначе
			Окно = Неопределено;
			Если ТипЗнч(ПараметрыОткрытия) = Тип("ПараметрыВыполненияКоманды")
				ИЛИ ТипЗнч(ПараметрыОткрытия) = Тип("Структура")
				И ПараметрыОткрытия.Свойство("Окно") И ТипЗнч(ПараметрыОткрытия.Окно) = Тип("ОкноКлиентскогоПриложения") Тогда
				
				Окно = ПараметрыОткрытия.Окно;
			КонецЕсли;
			
			Если ТипЗнч(ПараметрыОткрытия) = Тип("Структура") Тогда
				Если ПараметрыОткрытия.Свойство("ИсходныйДокумент") Тогда
					ПараметрыФормы.Вставить("ИсходныйДокумент", ПараметрыОткрытия.ИсходныйДокумент)
				КонецЕсли;
			КонецЕсли;

			ОткрытьФорму("Обработка.ЭлектронныеДокументы.Форма.ДеревоЭД", ПараметрыФормы,
				ПараметрыОткрытия.Источник, ПараметрыОткрытия.Уникальность, Окно);
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

Процедура ВыполнитьКомандуФормыДокумента(Объект, Форма, ИмяКоманды) Экспорт
	
	#Если ТолстыйКлиентОбычноеПриложение Тогда
		РезультатПроверки = Неопределено;
		ЭлектронныеДокументыКлиентПереопределяемый.ОбъектМодифицирован(Объект, Форма, РезультатПроверки);
		Если РезультатПроверки = Неопределено Тогда
			
			Если Форма.Модифицированность ИЛИ НЕ ЗначениеЗаполнено(Объект.Ссылка) Тогда
				
				Проведен    = Метаданные.Документы.Содержит(Объект.Метаданные()) И Объект.Проведен;
				СтрПроведен = ?(Проведен, "записать и провести.
				|Записать и провести?", "записать.
				|Записать?");
				
				ШаблонСообщения = ВернутьСтр("ru = 'Документ изменен. Для формирования электронного документа его необходимо %1'");
				ТекстВопроса = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонСообщения, СтрПроведен);
				
				ДополнительныеПараметры = Новый Структура();
				ДополнительныеПараметры.Вставить("СсылкаНаОбъект", Объект.Ссылка);
				ДополнительныеПараметры.Вставить("ИмяКоманды", ИмяКоманды);
				ДополнительныеПараметры.Вставить("Форма", Форма);
				ДополнительныеПараметры.Вставить("Проведен", Проведен);
				
				Обработчик = Новый ОписаниеОповещения( "ЗаписатьВФорме", ЭтотОбъект, ДополнительныеПараметры);
				
				ПоказатьВопрос( Обработчик, ТекстВопроса, РежимДиалогаВопрос.ОКОтмена, , КодВозвратаДиалога.Отмена, ВернутьСтр("ru = 'Документ изменен.'"));
				
			КонецЕсли;
		КонецЕсли;
	#КонецЕсли
	
	ВыполнитьКомандуЭДО(Объект.Ссылка, ИмяКоманды);
	
КонецПроцедуры

Процедура ЗаписатьВФорме(Ответ, ДополнительныеПараметры) Экспорт
	
	Если Ответ = КодВозвратаДиалога.ОК Тогда
		
		Проведен = ДополнительныеПараметры.Проведен;
		Форма = ДополнительныеПараметры.Форма;
		
		Если Проведен Тогда
			Попытка
				Отказ = Не Форма.ЗаписатьВФорме(РежимЗаписиДокумента.Проведение);
			Исключение
				ПоказатьПредупреждение(, ВернутьСтр("ru = 'Операция не выполнена!'"));
				Отказ = Истина;
			КонецПопытки;
		Иначе
			Отказ = Не Форма.ЗаписатьВФорме();
		КонецЕсли;
		
		Если Отказ Тогда
			Возврат;
		КонецЕсли;
	Иначе
		Возврат;
	КонецЕсли;
	
	СсылкаНаОбъект = ДополнительныеПараметры.СсылкаНаОбъект;
	ИмяКоманды = ДополнительныеПараметры.ИмяКоманды;
	
	ВыполнитьКомандуЭДО(СсылкаНаОбъект, ИмяКоманды);
	
	
КонецПроцедуры

Процедура ВыполнитьКомандуЭДО(СсылкаНаОбъект, ИмяКоманды)
	
	Если ИмяКоманды = "СформироватьПодписатьОтправитьЭД" Тогда
		СформироватьПодписатьОтправитьЭД(СсылкаНаОбъект);
		
	ИначеЕсли ИмяКоманды = "СформироватьНовыйЭД" Тогда
		СформироватьНовыйЭД(СсылкаНаОбъект);
		
	ИначеЕсли ИмяКоманды = "ОтправитьПовторно" Тогда
		ОтправитьПовторноЭД(СсылкаНаОбъект);
		
	ИначеЕсли ИмяКоманды = "ОткрытьАктуальныйЭД" Тогда
		ОткрытьАктуальныйЭД(СсылкаНаОбъект);
		
	ИначеЕсли ИмяКоманды = "БыстрыйОбменСформироватьНовыйЭД" Тогда
		 БыстрыйОбменСформироватьНовыйЭД(СсылкаНаОбъект);
		
	КонецЕсли;
		
КонецПроцедуры

// Процедура создает, подписывает и отправляет электронный документ.
//
// Параметры:
//  ПараметрКоманды - СсылкаНаОбъект - ссылка на объект ИБ, электронные документы которого надо отправить,
//  ЭД - электронный документ, который надо подписать, отправить.
//
Процедура СформироватьПодписатьОтправитьЭД(ПараметрКоманды, ЭД = Неопределено) Экспорт
	
	МассивСсылок = ЭлектронныеДокументыСлужебныйКлиент.ПолучитьМассивПараметров(ПараметрКоманды);
	Если МассивСсылок = Неопределено Тогда
		Если ЭД = Неопределено Тогда
			Возврат;
		Иначе
			МассивСсылок = Новый Массив;
		КонецЕсли;
	КонецЕсли;
	
	ЭлектронныеДокументыСлужебныйКлиент.ОбработатьЭД(МассивСсылок, "СформироватьУтвердитьПодписатьОтправить", , ЭД);
	
КонецПроцедуры

// Процедура создает новый электронный документ.
//
// Параметры:
//  ПараметрКоманды - СсылкаНаОбъект - ссылка на объект ИБ, электронные документы которого надо отправить,
//
Процедура СформироватьНовыйЭД(ПараметрКоманды, Показывать=Истина) Экспорт
	
	МассивСсылок = ЭлектронныеДокументыСлужебныйКлиент.ПолучитьМассивПараметров(ПараметрКоманды);
	Если МассивСсылок = Неопределено Тогда
		Возврат;
	КонецЕсли;
	Если Показывать Тогда
		ЭлектронныеДокументыСлужебныйКлиент.ОбработатьЭД(МассивСсылок, "СформироватьПоказать");
	Иначе
		ЭлектронныеДокументыСлужебныйКлиент.ОбработатьЭД(МассивСсылок, "Сформировать");
	КонецЕсли;
	
КонецПроцедуры

// Запускает мастер-помощник по подключению организации к прямому обмену с контрагентами.
//
Процедура ПомощникПодключенияКПрямомуОбмену() Экспорт
	
	СпособыОЭД = Новый Массив;
	СпособыОЭД.Добавить(ПредопределенноеЗначение("Перечисление.СпособыОбменаЭД.ЧерезКаталог"));
	СпособыОЭД.Добавить(ПредопределенноеЗначение("Перечисление.СпособыОбменаЭД.ЧерезЭлектроннуюПочту"));
	СпособыОЭД.Добавить(ПредопределенноеЗначение("Перечисление.СпособыОбменаЭД.ЧерезFTP"));
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("СпособыОбменаЭД", СпособыОЭД);
	ОткрытьФорму("Справочник.ПрофилиНастроекЭДО.Форма.ПомощникПодключенияЭДО", ПараметрыФормы);
	
КонецПроцедуры

// Запускает мастер-помощник по подключению организации к сервису 1С-Такском.
//
Процедура ПомощникПодключенияКСервису1СТакском() Экспорт
	
	СпособыОЭД = Новый Массив;
	СпособыОЭД.Добавить(ПредопределенноеЗначение("Перечисление.СпособыОбменаЭД.ЧерезОператораЭДОТакском"));
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("СпособыОбменаЭД", СпособыОЭД);
	ОткрытьФорму("Справочник.ПрофилиНастроекЭДО.Форма.ПомощникПодключенияЭДО", ПараметрыФормы);
	
КонецПроцедуры

// Процедура создает новый электронный документ.
//
// Параметры:
//  ПараметрКоманды - СсылкаНаОбъект - ссылка на объект ИБ, электронные документы которого надо отправить,
//
Процедура БыстрыйОбменСформироватьНовыйЭД(ПараметрКоманды) Экспорт
	
	МассивСсылок = ЭлектронныеДокументыСлужебныйКлиент.ПолучитьМассивПараметров(ПараметрКоманды);
	Если МассивСсылок = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Параметры = Новый Структура("СтруктураЭД", МассивСсылок);
	ФормаПросмотраЭД = ОткрытьФорму("Обработка.ЭлектронныеДокументы.Форма.ФормаВыгрузкаЭДВФайл", Параметры);
	
КонецПроцедуры

// Процедура создает новый электронный каталог.
//
Процедура БыстрыйОбменСформироватьНовыйЭДКаталог() Экспорт
	
	НазваниеСправочникаОрганизации = ЭлектронныеДокументыСлужебныйВызовСервера.ПолучитьИмяПрикладногоСправочника("Организации");
	Если Не ЗначениеЗаполнено(НазваниеСправочникаОрганизации) Тогда
		НазваниеСправочникаОрганизации = "Организации";
	КонецЕсли;
	
	
	Обработчик = Новый ОписаниеОповещения("СформироватьНовыйЭДКаталог", ЭтотОбъект);
	Режим = РежимОткрытияОкнаФормы.БлокироватьОкноВладельца;
	
	ОткрытьФорму("Справочник." + НазваниеСправочникаОрганизации + ".ФормаВыбора",,,,,, Обработчик, Режим);
	
КонецПроцедуры

// Описание оповещения для процедуры "БыстрыйОбменСформироватьНовыйЭДКаталог"
Процедура СформироватьНовыйЭДКаталог(Организация, ДополнительныеПараметры) Экспорт
	
	Если Организация = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ДопПараметры = Новый Структура("Организация", Организация);
	ОписаниеОповещения = Новый ОписаниеОповещения(
		"СформироватьНовыйЭДКаталогЗавершить", ЭлектронныеДокументыСлужебныйКлиент, ДопПараметры);
	ЭлектронныеДокументыКлиентПереопределяемый.ОткрытьФормуПодбораТоваров(Новый УникальныйИдентификатор(),
		ОписаниеОповещения);
	
КонецПроцедуры

// Процедура отправляет повторно электронный документ.
//
// Параметры:
//  ПараметрКоманды - СсылкаНаОбъект - ссылка на объект ИБ, электронные документы которого надо отправить,
//  ЭД - электронный документ, который надо подписать, отправить.
//
Процедура ОтправитьПовторноЭД(ПараметрКоманды, ЭД = Неопределено) Экспорт
	
	МассивСсылок = ЭлектронныеДокументыСлужебныйКлиент.ПолучитьМассивПараметров(ПараметрКоманды);
	Если МассивСсылок = Неопределено Тогда
		Если ЭД = Неопределено Тогда
			Возврат;
		Иначе
			МассивСсылок = Новый Массив;
		КонецЕсли;
	КонецЕсли;
	
	ЭлектронныеДокументыСлужебныйКлиент.ОбработатьЭД(МассивСсылок, "ОтправитьПовторно", , ЭД);
	
КонецПроцедуры

// Отправка и получение электронных документов одной командой.
//
//
Процедура ОтправитьПолучитьЭлектронныеДокументы() Экспорт
	
	ЭлектронныеДокументыСлужебныйКлиент.ОтправитьПолучитьЭлектронныеДокументы();
	
КонецПроцедуры

// Загружает файл электронного документа в документ ИБ.
//
// Параметры:
//  СсылкаНаДокумент - Ссылка на объект ИБ, данные которого необходимо перезаполнить.
//
Процедура БыстрыйОбменЗагрузитьЭД(СсылкаНаДокумент = Неопределено) Экспорт
	
	Файл = Неопределено;
	АдресВХранилище = Неопределено;
	УникальныйИдентификатор = Новый УникальныйИдентификатор;
	
	
	ДополнительныеПараметры = Новый Структура;
	ДополнительныеПараметры.Вставить("СсылкаНаДокумент", СсылкаНаДокумент);
	ДополнительныеПараметры.Вставить("УникальныйИдентификатор", УникальныйИдентификатор);
	
	Обработчик = Новый ОписаниеОповещения("ОбработатьРезультатПомещенияФайла", ЭтотОбъект, ДополнительныеПараметры);
	НачатьПомещениеФайла(Обработчик, АдресВХранилище, Файл, Истина, УникальныйИдентификатор);
		
КонецПроцедуры

Процедура ОбработатьРезультатПомещенияФайла(ВыборВыполнен, АдресФайла, ВыбранноеИмяФайла, ДополнительныеПараметры) Экспорт
	
	Если Не ВыборВыполнен Тогда
		Возврат;
	КонецЕсли;
	
	Расширение = Прав(ВыбранноеИмяФайла, 3);
	СсылкаНаДокумент = ДополнительныеПараметры.СсылкаНаДокумент;
	УникальныйИдентификатор = ДополнительныеПараметры.УникальныйИдентификатор;
	
	Если Не (ВРег(Расширение) = Врег("zip") Или Врег(Расширение) = Врег("xml")) Тогда
		ТекстСообщения = ВернутьСтр("ru = 'Не корректный формат файла.
		|Выберите файл с расширением ""zip"" или ""xml"".'");
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
		Возврат;
	КонецЕсли;
	
	СтруктураОбмена = Новый Структура("НаправлениеЭД, УникальныйИдентификатор, АдресХранилища, СсылкаНаДокумент, ИмяФайла, ФайлАрхива",
		ПредопределенноеЗначение("Перечисление.НаправленияЭД.Входящий"), УникальныйИдентификатор, АдресФайла,
		СсылкаНаДокумент, ВыбранноеИмяФайла, ВРег(Расширение) = Врег("zip"));
	
	Параметры = Новый Структура("СтруктураЭД", СтруктураОбмена);
	
	ОткрытьФорму("Обработка.ЭлектронныеДокументы.Форма.ФормаЗагрузкиПросмотраЭД", Параметры, ,
		СтруктураОбмена.УникальныйИдентификатор);
	
	
КонецПроцедуры

// Загружает файл электронного документа в данные ИБ, используется для вывода команды в интерфейсы.
//
Процедура БыстрыйОбменЗагрузитьЭДИзФайла() Экспорт
	
	БыстрыйОбменЗагрузитьЭД();
	
КонецПроцедуры

// Процедура принудительно закрывает электронный документооборот для массива ссылок на документы.
//
// Параметры:
//   МассивВладельцевЭД - Массив - содержит ссылки на документы ИБ, для которых требуется закрыть
//      электронный документооборот.
//
Процедура ЗакрытьПринудительноЭДО(МассивВладельцевЭД) Экспорт
	
	МассивСсылок = ЭлектронныеДокументыСлужебныйКлиент.ПолучитьМассивПараметров(МассивВладельцевЭД);
	Если МассивСсылок = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ДополнительныеПараметры = Новый Структура;
	ДополнительныеПараметры.Вставить("МассивСсылок", МассивСсылок);
	
	Обработчик = Новый ОписаниеОповещения("ЗакрытьПринудительноРезультатВводаСтроки", ЭтотОбъект, ДополнительныеПараметры);
	
	ПричинаЗакрытия = "";
	ПоказатьВводСтроки(Обработчик, ПричинаЗакрытия, ВернутьСтр("ru = 'Укажите причину закрытия документооборота'"),,Истина);
	
	
КонецПроцедуры

Процедура ЗакрытьПринудительноРезультатВводаСтроки(ПричинаЗакрытия, ДополнительныеПараметры) Экспорт
	
	Если Не ЗначениеЗаполнено(ПричинаЗакрытия) Тогда
		
		ТекстСообщения = ВернутьСтр("ru = 'Для закрытия документооборота по выбранным ЭД необходимо указать причину закрытия!'");
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
		Возврат;
		
	КонецЕсли;
	
	МассивСсылок = ДополнительныеПараметры.МассивСсылок;
	КоличествоОбработанныхЭД = 0;
	ЭлектронныеДокументыСлужебныйВызовСервера.ЗакрытьДокументыПринудительно(МассивСсылок, ПричинаЗакрытия, КоличествоОбработанныхЭД);
	
	ТекстОповещения = ВернутьСтр("ru = 'Изменено состояние ЭД документов на ""Закрыт принудительно"": (%1)'");
	ТекстОповещения = СтрЗаменить(ТекстОповещения, "%1", КоличествоОбработанныхЭД);
	ПоказатьОповещениеПользователя(ВернутьСтр("ru = 'Обработка документов'"), , ТекстОповещения);
	Если КоличествоОбработанныхЭД > 0 Тогда
		Оповестить("ОбновитьСостояниеЭД");
	КонецЕсли;
	
КонецПроцедуры

// Открывается форма списка только с закладкой Настройки ЭДО с контрагентами.
//
Процедура ОткрытьФормуНастроекЭДОСКонтрагентами() Экспорт
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("НастройкиЭДОСКонтрагентами", Истина);
	ОткрытьФорму("Справочник.СоглашенияОбИспользованииЭД.Форма.ФормаСписка", ПараметрыФормы);
	
КонецПроцедуры

// Запускает обработку "Текущие дела ЭДО".
//
Процедура ОткрытьТекущиеДелаЭДО() Экспорт
	
	ОткрытьФорму("Обработка.ТекущиеДелаПоЭДО.Форма");
	
КонецПроцедуры

#Область Сервис1СЭДО

// Запускает мастер-помощник по подключению организации к сервису 1С-ЭДО.
//
Процедура ПомощникПодключенияКСервису1СЭДО() Экспорт
	
	СпособыОЭД = Новый Массив;
	СпособыОЭД.Добавить(ПредопределенноеЗначение("Перечисление.СпособыОбменаЭД.ЧерезСервис1СЭДО"));
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("СпособыОбменаЭД", СпособыОЭД);
	ОткрытьФорму("Справочник.ПрофилиНастроекЭДО.Форма.ПомощникПодключенияЭДО", ПараметрыФормы);
	
КонецПроцедуры

// Открывает рекламную форму сервиса 1С-ЭДО.
//
Процедура ПредложениеОформитьЗаявлениеНаПодключение(Контрагент = Неопределено, Организация = Неопределено) Экспорт
	
	ПараметрыОткрытия = Новый Структура();
	ПараметрыОткрытия.Вставить("Контрагент", Контрагент);
	ПараметрыОткрытия.Вставить("Организация", Организация);
	
	ОткрытьФорму("ОбщаяФорма.ПредложениеОформитьЗаявлениеНаПодключение", ПараметрыОткрытия,,,,,,РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
КонецПроцедуры

#КонецОбласти

#Область ПередачаЭДвФНС

// Получает документы информационной базы по заданным критериям отбора.
// Процедура предназначена для использования совместно с библиотекой "Регламентированная отчетность".
//
// Параметры:
//  СтруктураОтбора - структура, параметры отбора для формы выбора документов ИБ;
//
Процедура ПолучитьСвойстваДокументовИБДляПередачиФНС(СтруктураОтбора = Неопределено) Экспорт
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("ВерсияВызова", 3);
	
	Если СтруктураОтбора <> Неопределено Тогда
		Если СтруктураОтбора.Свойство("ВидДокумента") Тогда
			ПараметрыФормы.Вставить("ВидДокумента", СтруктураОтбора.ВидДокумента);
		КонецЕсли;
		
		Если СтруктураОтбора.Свойство("Организация") Тогда
			ПараметрыФормы.Вставить("Организация", СтруктураОтбора.Организация);
		КонецЕсли;
		
		Если СтруктураОтбора.Свойство("Контрагент") Тогда
			ПараметрыФормы.Вставить("Контрагент", СтруктураОтбора.Контрагент);
		КонецЕсли;
	КонецЕсли;
	ОткрытьФорму("Обработка.ЭлектронныеДокументы.Форма.ФормаВыбораЭДДляПередачиФНС", ПараметрыФормы);
	
КонецПроцедуры

// Устарела. Следует использовать процедуру ПолучитьСвойстваДокументовИБДляПередачиФНС
// Получает документы информационной базы по заданным критериям отбора.
// Функция предназначена для использования совместно с библиотекой "Регламентированная отчетность".
//
// Параметры:
//  СтруктураОтбора - структура, параметры отбора для формы выбора документов ИБ;
//  МножественныйВыбор - булево, свойство формы выбора.
//
Функция ПолучитьДокументыИБДляПередачиФНС(СтруктураОтбора, МножественныйВыбор) Экспорт
	
	
КонецФункции

#КонецОбласти

#Область ПрямойОбменСБанком

// Отправляет запрос выписки в банк, а после получения выписки вызывает оповещение о выборе
// для формы или элемента формы, указанного в параметре Владелец
//
// Параметры:
//  НастройкаЭДО - СправочникСсылка.СоглашениеОбИспользованииЭД - текущая настройка обмена с банком;
//  ДатаНачала - дата, начало периода запроса
//  ДатаОкончания - дата, окончание периода запроса
//  Владелец - Форма или элемент формы - получатель оповещения о выборе элемента - выписки банка
//  НомерСчета - Строка, номер банковского счета организации. Если не указан, то запрос по всем счетам;
//
Процедура ПолучитьВыпискуБанка(НастройкаЭДО, ДатаНачала, Знач ДатаОкончания, Владелец, НомерСчета = Неопределено) Экспорт
	
	Если Не ЗначениеЗаполнено(НастройкаЭДО) Тогда
		Возврат;
	КонецЕсли;
	
	ТекущаяДатаСеанса = ОбщегоНазначенияКлиент.ДатаСеанса();
	Если ДатаНачала > ТекущаяДатаСеанса ИЛИ ДатаОкончания > КонецДня(ТекущаяДатаСеанса) Тогда
		СообщениеТекст = ВернутьСтр("ru = 'Период запроса указан неверно'");
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(СообщениеТекст, , "Период");
		Возврат;
	КонецЕсли;
	
	Если КонецДня(ДатаОкончания) = КонецДня(ТекущаяДатаСеанса) Тогда
		ДатаОкончания = ТекущаяДатаСеанса;
	Иначе
		ДатаОкончания = КонецДня(ДатаОкончания);
	КонецЕсли;
	
	РеквизитыНастройкиЭДО = ЭлектронныеДокументыСлужебныйВызовСервера.РеквизитыНастройкиЭДО(НастройкаЭДО);
	
	СтатусДействует = ПредопределенноеЗначение("Перечисление.СтатусыСоглашенийЭД.Действует");
	Если Не РеквизитыНастройкиЭДО.СтатусСоглашения = СтатусДействует Тогда
		ТекстСообщения = ВернутьСтр("ru = 'Настройка ЭДО не действует, операция невозможна'");
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
		Возврат;
	КонецЕсли;
	
	Параметры = Новый Структура;
	
	Параметры.Вставить("СоглашениеЭД", НастройкаЭДО);
	Параметры.Вставить("НомерСчета", НомерСчета);
	Параметры.Вставить("ДатаНачала", ДатаНачала);
	Параметры.Вставить("ДатаОкончания", ДатаОкончания);
	Параметры.Вставить("Владелец", Владелец);
	Параметры.Вставить("РеквизитыНастройкиЭДО", РеквизитыНастройкиЭДО);
	
	ОбменЧерезДопОбработку = ПредопределенноеЗначение("Перечисление.ПрограммыБанка.ОбменЧерезДопОбработку");
	СбербанкОнлайн = ПредопределенноеЗначение("Перечисление.ПрограммыБанка.СбербанкОнлайн");
	Если РеквизитыНастройкиЭДО.ПрограммаБанка = ОбменЧерезДопОбработку Тогда
		// СтруктураПодключения нужна для получения внешнего модуля.
		СтруктураПодключения = Новый Структура;
		СтруктураПодключения.Вставить("СоглашениеЭД", НастройкаЭДО);
		СтруктураПодключения.Вставить("ВыполняласьПопыткаПолученияМодуля", Ложь);
		
		ОбработчикПослеПодключения = Новый ОписаниеОповещения("ПолучитьВыпискуЧерезДополнительнуюОбработку",
			ЭлектронныеДокументыСлужебныйКлиент, Параметры);
		СтруктураПодключения.Вставить("ОбработкаПослеПолученияМодуля", ОбработчикПослеПодключения);
		
		ЭлектронныеДокументыСлужебныйКлиент.ПолучитьВнешнийМодульЧерезДополнительнуюОбработку(СтруктураПодключения);
		Возврат;
	ИначеЕсли РеквизитыНастройкиЭДО.ПрограммаБанка = ПредопределенноеЗначение("Перечисление.ПрограммыБанка.iBank2") Тогда
		ОО = Новый ОписаниеОповещения("ПолучитьВыпискуiBank2", ЭлектронныеДокументыСлужебныйКлиент, Параметры);
		Параметры.Вставить("ОбработчикПослеПодключенияКомпоненты", ОО);
		ЭлектронныеДокументыСлужебныйКлиент.ПодключитьВнешнююКомпонентуiBank2(Параметры);
		Возврат;
	ИначеЕсли РеквизитыНастройкиЭДО.ПрограммаБанка = СбербанкОнлайн Тогда
		ГотовыеВыписки = Неопределено;
		ЭД = ЭлектронныеДокументыСлужебныйВызовСервера.ЭДЗапросВыпискиСбербанк(
			НастройкаЭДО, ДатаНачала, ДатаОкончания, НомерСчета, ГотовыеВыписки);
		Параметры.Вставить("ГотовыеВыписки", ГотовыеВыписки);
		Параметры.Вставить("ЭлектронныйДокумент", ЭД);
		Параметры.Вставить("НомерСчета", НомерСчета);
			
		Если ЗначениеЗаполнено(ЭД) Тогда
			ОписаниеОбработчика = Новый ОписаниеОповещения(
				"ОтправитьЗапросВыпискиПослеУстановленияКаналаСбербанк", ЭлектронныеДокументыСлужебныйКлиент, Параметры);
				
			КаналУстановлен = Ложь;
			ЭлектронныеДокументыСлужебныйКлиент.УстановитьВиртуальныйКаналСоСбербанком(
				НастройкаЭДО, КаналУстановлен, ОписаниеОбработчика, Параметры);
	
			Если Не КаналУстановлен Тогда
				Возврат;
			КонецЕсли;
		КонецЕсли;
		
		ЭлектронныеДокументыСлужебныйКлиент.ОтправитьЗапросВыпискиПослеУстановленияКаналаСбербанк(НастройкаЭДО, Параметры);
		Возврат;
		
	КонецЕсли;
	
	Если РеквизитыНастройкиЭДО.ИспользуетсяКриптография Тогда
		Оповещение = Новый ОписаниеОповещения(
			"ПослеПолученияОтпечатковПолучитьВыпискуБанка", ЭлектронныеДокументыСлужебныйКлиент, Параметры);
		ЭлектроннаяПодписьКлиент.ПолучитьОтпечаткиСертификатов(Оповещение, Истина, Ложь);
		Возврат;
	Иначе
		МассивОтпечатковСертификатов = Новый Массив;
	КонецЕсли;
	
	ЭлектронныеДокументыСлужебныйКлиент.ПослеПолученияОтпечатковПолучитьВыпискуБанка(
											МассивОтпечатковСертификатов, Параметры);
	
КонецПроцедуры

// Отправляет подготовленные документы в банк и получает новые.
// Если параметры не переданы то выполняется синхронизация по всем настройкам с банками
//
// Параметры:
//  Организация - СправочникСсылка.Организации, организация из расчетного счета
//  Банк - СправочникСсылка.КлассификаторБанковРФ - банк из расчетного счета
//
Процедура СинхронизироватьСБанком(Организация = Неопределено, Банк = Неопределено) Экспорт
	
	#Если ТолстыйКлиентОбычноеПриложение Тогда
		Если НЕ ЭлектронныеДокументыПереопределяемый.ЕстьПравоОбработкиЭД() Тогда
			ЭлектронныеДокументыСлужебныйКлиент.СообщитьПользователюОНарушенииПравДоступа();
			Возврат;
		КонецЕсли;
		Если НЕ ЭлектронныеДокументыСлужебныйВызовСервера.ПолучитьЗначениеФункциональнойОпции("ИспользоватьОбменЭД") Тогда
			ТекстСообщения = ЭлектронныеДокументыСлужебныйВызовСервера.ТекстСообщенияОНеобходимостиНастройкиСистемы("РаботаСЭД");
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
			Возврат;
		КонецЕсли;
	#КонецЕсли
	
	МассивНастроекЭДО = ЭлектронныеДокументыСлужебныйВызовСервера.НастройкиЭДОСБанками(Организация, Банк);
	
	ПараметрыСихронизации = Новый Структура;
	ПараметрыСихронизации.Вставить("НастройкиЭДОСБанками", МассивНастроекЭДО);
	ПараметрыСихронизации.Вставить("ИтогКолПодготовленных", 0);
	ПараметрыСихронизации.Вставить("ИтогКолОтправленных", 0);
	
	ЭлектронныеДокументыСлужебныйКлиент.ВыполнитьОбменСБанками(Неопределено, ПараметрыСихронизации);

КонецПроцедуры

// Создает настройку ЭДО с банком или открывает существующую
// Если банк не известен системе, то открывается форма Настройки ЭДО с банком,
// в которой заполнена только Организация и Банк
// Если банк известен системе, но не поддерживает автоматическое получение настроек,
// то предлагается выбор файла настроек, загружает настройки из файла
// и открывает заполненную форму настроек ЭДО с банком
// Если банк известен системе и поддерживает автоматическое получение настроек,
// то настройка создается автоматически и производится тест настроек.
//
// Параметры:
//  Организация - СправочникСсылка.Организации - ссылка на организацию
//  Банк - СправочникСсылка.КлассификаторБанковРФ - ссылка на банк
//  НомерСчета - Строка - номер банковского счета
//  ОбработчикОповещения - ОписаниеОповещения - содержит описание процедуры,
//   которая будет вызвана после создания настройки ЭДО с банком со следующими параметрами: 
//    * НастройкаЭДО – СправочникСсылка.СоглашенияОбИспользованииЭД - созданная настройка ЭДО
//    * ДополнительныеПараметры - значение, которое было указано при создании объекта ОписаниеОповещения.
//  Оповещение не вызывается если настройка ЭДО уже существует
Процедура ОткрытьСоздатьНастройкуЭДОСБанком(Организация, Банк, НомерСчета = "", ОбработчикОповещения) Экспорт
	
	ТекущаяНастройка = ЭлектронныеДокументыСлужебныйВызовСервера.НастройкаЭДОСБанком(Организация, Банк);
	Если ЗначениеЗаполнено(ТекущаяНастройка) Тогда
		ПоказатьЗначение( ,ТекущаяНастройка);
		Возврат;
	КонецЕсли;
	
	НастройкиОбменаСБанком = ЭлектронныеДокументыСлужебныйВызовСервера.НастройкиОбменаСБанком(Банк);
	
	Если ЗначениеЗаполнено(НастройкиОбменаСБанком) И НастройкиОбменаСБанком.СпособАутентификации = "ИзФайла" Тогда
		ЭлектронныеДокументыСлужебныйКлиент.ЗагрузитьНастройкуЭДОИзФайла(ОбработчикОповещения);
	ИначеЕсли ЗначениеЗаполнено(НастройкиОбменаСБанком)
		И НастройкиОбменаСБанком.СпособАутентификации = "ПоСертификату" Тогда
		Параметры = Новый Структура;
		Параметры.Вставить("Организация", Организация);
		Параметры.Вставить("Банк", Банк);
		Параметры.Вставить("ОбработчикПослеСозданияНастройкиЭДО", ОбработчикОповещения);
		Параметры.Вставить("АдресСервера", НастройкиОбменаСБанком.АдресСервера);
		Параметры.Вставить("НомерСчета", НомерСчета);
		Параметры.Вставить("СпособАутентификации", "ПоСертификату");
		Оповещение = Новый ОписаниеОповещения(
			"ПолучитьЛичныеСертификатыПослеСозданияМенеджераКриптографии", ЭлектронныеДокументыСлужебныйКлиент, Параметры);
		ЭлектроннаяПодписьКлиент.СоздатьМенеджерКриптографии(Оповещение, "ПолучениеСертификатов");
	ИначеЕсли ЗначениеЗаполнено(НастройкиОбменаСБанком)
		И НастройкиОбменаСБанком.СпособАутентификации = "ПоЛогинуИПаролю" Тогда
		Параметры = Новый Структура;
		Параметры.Вставить("Организация", Организация);
		Параметры.Вставить("Банк", Банк);
		Параметры.Вставить("ОбработчикПослеСозданияНастройкиЭДО", ОбработчикОповещения);
		Параметры.Вставить("АдресСервера", НастройкиОбменаСБанком.АдресСервера);
		Параметры.Вставить("НомерСчета", НомерСчета);
		ПараметрыФормы = Новый Структура("СпособАутентификации", "ПоЛогинуИПаролю");
		Оповещение = Новый ОписаниеОповещения(
			"ПолучитьМаркерПослеВводаДанныхАутентификации", ЭлектронныеДокументыСлужебныйКлиент, Параметры);
		ОткрытьФорму("Обработка.ОбменЭлектроннымиДокументамиСБанком.Форма.ПолучениеНастроекИзБанка", ПараметрыФормы, , ,
			ВариантОткрытияОкна.ОтдельноеОкно, , Оповещение);
	ИначеЕсли ЗначениеЗаполнено(НастройкиОбменаСБанком)
		И НастройкиОбменаСБанком.СпособАутентификации = "ПоЛогинуИлиСертификату" Тогда
		Параметры = Новый Структура;
		Параметры.Вставить("Организация", Организация);
		Параметры.Вставить("Банк", Банк);
		Параметры.Вставить("ОбработчикПослеСозданияНастройкиЭДО", ОбработчикОповещения);
		Параметры.Вставить("АдресСервера", НастройкиОбменаСБанком.АдресСервера);
		Параметры.Вставить("НомерСчета", НомерСчета);
		Параметры.Вставить("СпособАутентификации", "ПоЛогинуИлиСертификату");
		Оповещение = Новый ОписаниеОповещения(
			"ПолучитьЛичныеСертификатыПослеСозданияМенеджераКриптографии", ЭлектронныеДокументыСлужебныйКлиент, Параметры);
		ЭлектроннаяПодписьКлиент.СоздатьМенеджерКриптографии(Оповещение, "ПолучениеСертификатов");
	Иначе
		ПараметрыФормы = Новый Структура("Организация, Контрагент", Организация, Банк);
		ОткрытьФорму("Справочник.СоглашенияОбИспользованииЭД.Форма.ФормаЭлементаБанк", ПараметрыФормы);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти
