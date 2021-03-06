//Обновление рег. Отчетности на бух. Корп 3.0.36.18
//Отредактировано создание описания оповещения: ЭтотОбъект -> *ИмяМодуля*
//<=                            

// Процедура получает Контекст ЭДО и возвращает его в Обработку оповещения, 
// переданную в параметрах к этой процедуре.
// 
//
// Параметры:
//	ВыполняемоеОповещение                  - ОписаниеОповещения - Описание оповещения, которое будет вызвано после получения Контекста ЭДО.
//                                                       В качестве результата описания оповещения передается структура с ключами: 
//                                                       * КонтекстЭДО    - Форма обработки, либо неопределено 
//                                                       * ТекстОшибки - Текст сообщения об ошибке, из-за которой не удалось получить контекст
//	ВызовИзМастераПодключенияК1СОтчетности - Булево - .
//
Процедура ПолучитьКонтекстЭДО(ВыполняемоеОповещение, ОбновитьСейчас = Ложь, ТихийРежим = Ложь) Экспорт
	
	ТекстСообщения = "";
	
	СтруктураПараметров = Новый Структура("КонтекстЭДО");
	Оповестить("Получение контекста ЭДО", СтруктураПараметров);
	
	Если СтруктураПараметров.КонтекстЭДО <> Неопределено И НЕ ОбновитьСейчас Тогда
		
		СтруктураРезультата = Новый Структура;
		СтруктураРезультата.Вставить("ТекстОшибки", ТекстСообщения);
		СтруктураРезультата.Вставить("КонтекстЭДО", СтруктураПараметров.КонтекстЭДО);
		глКонтекстЭДО = СтруктураПараметров.КонтекстЭДО;

		ВыполнитьОбработкуОповещения(ВыполняемоеОповещение, СтруктураРезультата);
		
	ИначеЕсли НЕ ЭлектронныйДокументооборотСКонтролирующимиОрганамиВызовСервераПовтИсп.РазделениеВключено() И ДокументооборотСКОВызовСервера.ПодключатьВнешнююОбработкуЭДО() Тогда
		Если ДокументооборотСКОВызовСервера.ЕстьПравоНаДОсКО(Истина) Тогда
			Попытка
				ФормаРезультат = ПолучитьФорму("ВнешняяОбработка.Обработка_ДокументооборотСКО.Форма.КонтейнерКлиентскихМетодов");
				ФормаРезультат.ПутьКОбъекту = "ВнешняяОбработка.Обработка_ДокументооборотСКО";
			Исключение
				Состояние(ВернутьСтр("ru = 'Не удалось загрузить внешний модуль для документооборота с налоговыми органами.
					|Будет использован модуль, встроенный в конфигурацию.'"));
				ФормаРезультат = ПолучитьФорму("Обработка.ДокументооборотСКонтролирующимиОрганами.Форма.КонтейнерКлиентскихМетодов");
				ФормаРезультат.ПутьКОбъекту = "Обработка.ДокументооборотСКонтролирующимиОрганами";
			КонецПопытки;
			
			// Проверка обновления
			ДополнительныеПараметры = Новый Структура("ВыполняемоеОповещение, ФормаРезультат", ВыполняемоеОповещение, ФормаРезультат);
			ОписаниеОповещения = Новый ОписаниеОповещения("ПолучитьКонтекстЭДОЗавершение", ДокументооборотСКОКлиент, ДополнительныеПараметры);
			
			ФормаРезультат.ОбновитьМодульДокументооборотаСФНСПриНеобходимости(ОбновитьСейчас, ОписаниеОповещения, ТихийРежим);
				
		Иначе
			ТекстСообщения = ВернутьСтр("ru = 'Недостаточно прав для использования методов электронного документооборота с контролирующими органами.'");
			
			СтруктураРезультата = Новый Структура;
			СтруктураРезультата.Вставить("ТекстОшибки", ТекстСообщения);
			СтруктураРезультата.Вставить("КонтекстЭДО", Неопределено);
			глКонтекстЭДО = Неопределено;

			ВыполнитьОбработкуОповещения(ВыполняемоеОповещение, СтруктураРезультата);
		КонецЕсли;
		
	Иначе
		Если ДокументооборотСКОВызовСервера.ЕстьПравоНаДОсКО(Ложь) Тогда
			ФормаРезультат = ПолучитьФорму("Обработка.ДокументооборотСКонтролирующимиОрганами.Форма.КонтейнерКлиентскихМетодов");
			ФормаРезультат.ПутьКОбъекту = "Обработка.ДокументооборотСКонтролирующимиОрганами";
			
			// Проверка обновления
			ДополнительныеПараметры = Новый Структура("ВыполняемоеОповещение, ФормаРезультат", ВыполняемоеОповещение, ФормаРезультат);
			ОписаниеОповещения = Новый ОписаниеОповещения("ПолучитьКонтекстЭДОЗавершение", ДокументооборотСКОКлиент, ДополнительныеПараметры);
			
			ФормаРезультат.ОбновитьМодульДокументооборотаСФНСПриНеобходимости(ОбновитьСейчас, ОписаниеОповещения, ТихийРежим);
			
		Иначе
			ТекстСообщения = ВернутьСтр("ru = 'Недостаточно прав для использования методов электронного документооборота с контролирующими органами.'");
			
			СтруктураРезультата = Новый Структура;
			СтруктураРезультата.Вставить("ТекстОшибки", ТекстСообщения);
			СтруктураРезультата.Вставить("КонтекстЭДО", Неопределено);
			глКонтекстЭДО = Неопределено;

			ВыполнитьОбработкуОповещения(ВыполняемоеОповещение, СтруктураРезультата);
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры //ПолучитьКонтекстЭДО()

Процедура ОбновитьИПолучитьКонтекстЭДО(ВыполняемоеОповещение)
	
	Попытка
		КонтекстИнициализирован = ДокументооборотСКОВызовСервера.ИнициализироватьКонтекстДокументооборотаСНалоговымиОрганами();
	Исключение
		КонтекстИнициализирован = Ложь;
		ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ВернутьСтр("ru = 'Не удалось загрузить внешний модуль для документооборота с налоговыми органами.
			|%1
			|Будет продолжено использование текущего модуля конфигурации.'"), ИнформацияОбОшибке().Описание);
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстОшибки);
	КонецПопытки;
	
	Если КонтекстИнициализирован Тогда
		Попытка
			ФормаРезультат = ПолучитьФорму("ВнешняяОбработка.Обработка_ДокументооборотСКО.Форма.КонтейнерКлиентскихМетодов");
			ФормаРезультат.ПутьКОбъекту = "ВнешняяОбработка.Обработка_ДокументооборотСКО";
		Исключение
			Состояние(ВернутьСтр("ru = 'Не удалось загрузить внешний модуль для документооборота с налоговыми органами.
				|Будет использован модуль, встроенный в конфигурацию.'"));
			ФормаРезультат = ПолучитьФорму("Обработка.ДокументооборотСКонтролирующимиОрганами.Форма.КонтейнерКлиентскихМетодов");
			ФормаРезультат.ПутьКОбъекту = "Обработка.ДокументооборотСКонтролирующимиОрганами";
		КонецПопытки;
	КонецЕсли;
	
	СтруктураРезультата = Новый Структура;
	СтруктураРезультата.Вставить("ТекстОшибки", "");
	СтруктураРезультата.Вставить("КонтекстЭДО", ФормаРезультат);
	глКонтекстЭДО = ФормаРезультат;
	
	ВыполнитьОбработкуОповещения(ВыполняемоеОповещение, СтруктураРезультата);
	
КонецПроцедуры

Процедура ПолучитьКонтекстЭДОЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	ВыполняемоеОповещение = ДополнительныеПараметры.ВыполняемоеОповещение;
	ФормаРезультат = ДополнительныеПараметры.ФормаРезультат;
	
	Если Результат Тогда
		
		ОбновитьИПолучитьКонтекстЭДО(ВыполняемоеОповещение);
		
	Иначе
		
		СтруктураРезультата = Новый Структура;
		СтруктураРезультата.Вставить("ТекстОшибки", "");
		СтруктураРезультата.Вставить("КонтекстЭДО", ФормаРезультат);
		глКонтекстЭДО = ФормаРезультат;
		
		ВыполнитьОбработкуОповещения(ВыполняемоеОповещение, СтруктураРезультата);
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ПриНажатииНаКнопкуОтправкиВКонтролирующийОрган(Форма, КонтролирующийОрган, ЭтоОтправкаИзФормыОтчетность = Ложь, СсылкаНаОтчет = Неопределено, ОрганизацияОтчета = Неопределено) Экспорт
	
	Если НЕ ЭтоОтправкаИзФормыОтчетность Тогда
		СсылкаНаОтчет = ЭлектронныйДокументооборотСКонтролирующимиОрганамиКлиентСервер.СсылкаНаОтчетПоФорме(Форма);
	КонецЕсли;
	
	ТипЗнчСсылкаНаОтчет = ТипЗнч(СсылкаНаОтчет);
	ИмяДокументаУведомлениеОКонтролируемыхСделках 	= ЭлектронныйДокументооборотСКонтролирующимиОрганамиКлиентСерверПереопределяемый.ИмяОбъектаМетаданных("УведомлениеОКонтролируемыхСделках");
	ИмяДокументаИсходящееУведомлениеФНС 			= "УведомлениеОСпецрежимахНалогообложения";
	
	ИмяДокументаЗаявлениеОВвозеТоваров 	= ЭлектронныйДокументооборотСКонтролирующимиОрганамиКлиентСерверПереопределяемый.ИмяОбъектаМетаданных("ЗаявлениеОВвозеТоваров");
	
	Если ИмяДокументаЗаявлениеОВвозеТоваров <> Неопределено И ТипЗнчСсылкаНаОтчет = Тип("ДокументСсылка." + ИмяДокументаЗаявлениеОВвозеТоваров) Тогда
		ЭтоЗаявлениеОВвозе = Истина;
	Иначе
		ЭтоЗаявлениеОВвозе = Ложь;
	КонецЕсли;
	
	Если (ИмяДокументаУведомлениеОКонтролируемыхСделках <> Неопределено И ТипЗнчСсылкаНаОтчет = Тип("ДокументСсылка." + ИмяДокументаУведомлениеОКонтролируемыхСделках))
		ИЛИ (ИмяДокументаИсходящееУведомлениеФНС <> Неопределено И ТипЗнчСсылкаНаОтчет = Тип("ДокументСсылка." + ИмяДокументаИсходящееУведомлениеФНС)) Тогда
		ЭтоУведомлениеФНС = Истина;
	Иначе
		ЭтоУведомлениеФНС = Ложь;
	КонецЕсли;
	
	
	Если ТипЗнчСсылкаНаОтчет = Тип("ДокументСсылка.РегламентированныйОтчет")
		ИЛИ ТипЗнчСсылкаНаОтчет = Тип("Неопределено") Тогда
		
		Если НЕ ЭтоОтправкаИзФормыОтчетность Тогда
			// отправляем только из записанной формы
			Если Форма.Модифицированность Тогда
				ДополнительныеПараметры = Новый Структура;
				ДополнительныеПараметры.Вставить("СсылкаНаОтчет",СсылкаНаОтчет);
				ДополнительныеПараметры.Вставить("Форма",Форма);
				ДополнительныеПараметры.Вставить("КонтролирующийОрган",КонтролирующийОрган);
				ДополнительныеПараметры.Вставить("ЭтоОтправкаИзФормыОтчетность",ЭтоОтправкаИзФормыОтчетность);
				ДополнительныеПараметры.Вставить("СсылкаНаОтчет",СсылкаНаОтчет);
				ДополнительныеПараметры.Вставить("ОрганизацияОтчета",ОрганизацияОтчета);
				ДополнительныеПараметры.Вставить("ЭтоУведомлениеФНС",ЭтоУведомлениеФНС);
				ОписаниеОповещения = Новый ОписаниеОповещения("ПриНажатииНаКнопкуОтправкиВКонтролирующийОрганЗавершение", ДокументооборотСКОКлиент, ДополнительныеПараметры);
				Форма.СохранитьНаКлиенте(,ОписаниеОповещения);
			Иначе
				ОтправкаВКонтролирующийОрганПослеСохранения(Форма, КонтролирующийОрган, ЭтоОтправкаИзФормыОтчетность, СсылкаНаОтчет, ОрганизацияОтчета, ЭтоУведомлениеФНС);
			КонецЕсли;
		Иначе
			ОтправкаВКонтролирующийОрганПослеСохранения(Форма, КонтролирующийОрган, ЭтоОтправкаИзФормыОтчетность, СсылкаНаОтчет, ОрганизацияОтчета, ЭтоУведомлениеФНС);
		КонецЕсли;
			
	ИначеЕсли ЭтоУведомлениеФНС Тогда
		
		Если НЕ ЗначениеЗаполнено(СсылкаНаОтчет) Тогда
			ПоказатьПредупреждение(,"Перед отправкой необходимо записать уведомление.");
			Возврат;
		КонецЕсли;
		
		Если НЕ ЭтоОтправкаИзФормыОтчетность И Форма.Модифицированность Тогда
			ПоказатьПредупреждение(, "Перед отправкой необходимо записать уведомление.");
			Возврат;
		КонецЕсли;
		ОтправкаВКонтролирующийОрганПослеСохранения(Форма, КонтролирующийОрган, ЭтоОтправкаИзФормыОтчетность, СсылкаНаОтчет, ОрганизацияОтчета, ЭтоУведомлениеФНС);
		
	ИначеЕсли ЭтоЗаявлениеОВвозе Тогда
		
		Если НЕ ЗначениеЗаполнено(СсылкаНаОтчет) Тогда
			ПоказатьПредупреждение(,"Перед отправкой необходимо записать заявление.");
			Возврат;
		КонецЕсли;
		
		Если НЕ ЭтоОтправкаИзФормыОтчетность И Форма.Модифицированность Тогда
			ПоказатьПредупреждение(, "Перед отправкой необходимо записать заявление.");
			Возврат;
		КонецЕсли;
		ОтправкаВКонтролирующийОрганПослеСохранения(Форма, КонтролирующийОрган, ЭтоОтправкаИзФормыОтчетность, СсылкаНаОтчет, ОрганизацияОтчета, ЭтоУведомлениеФНС);
		
	Иначе
		
		ОтправкаВКонтролирующийОрганПослеСохранения(Форма, КонтролирующийОрган, ЭтоОтправкаИзФормыОтчетность, СсылкаНаОтчет, ОрганизацияОтчета, ЭтоУведомлениеФНС);
		
	КонецЕсли;

КонецПроцедуры

Процедура ПриНажатииНаКнопкуОтправкиВКонтролирующийОрганЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	СсылкаНаОтчет = ДополнительныеПараметры.СсылкаНаОтчет;
	Форма = ДополнительныеПараметры.Форма;
	КонтролирующийОрган = ДополнительныеПараметры.КонтролирующийОрган;
	ЭтоОтправкаИзФормыОтчетность = ДополнительныеПараметры.ЭтоОтправкаИзФормыОтчетность;
	СсылкаНаОтчет = ДополнительныеПараметры.СсылкаНаОтчет;
	ОрганизацияОтчета = ДополнительныеПараметры.ОрганизацияОтчета;
	ЭтоУведомлениеФНС = ДополнительныеПараметры.ЭтоУведомлениеФНС;
	
	Если СсылкаНаОтчет = Неопределено Тогда
		СсылкаНаОтчет = ЭлектронныйДокументооборотСКонтролирующимиОрганамиКлиентСервер.СсылкаНаОтчетПоФорме(Форма);
	КонецЕсли;
	
	ОтправкаВКонтролирующийОрганПослеСохранения(Форма, КонтролирующийОрган, ЭтоОтправкаИзФормыОтчетность, СсылкаНаОтчет, ОрганизацияОтчета, ЭтоУведомлениеФНС);
	
КонецПроцедуры

Процедура ОтправкаВКонтролирующийОрганПослеСохранения(Форма, КонтролирующийОрган, ЭтоОтправкаИзФормыОтчетность, СсылкаНаОтчет, ОрганизацияОтчета, ЭтоУведомлениеФНС)
	
	Если НЕ ЭтоОтправкаИзФормыОтчетность Тогда
		ОрганизацияОтчета = ДокументооборотСКОКлиентСервер.ПолучитьОрганизациюПоФорме(Форма);
	КонецЕсли;
	
	НастроенОбменВУниверсальномФормате = Ложь;
	УчетнаяЗаписьПредназначенаДляДокументооборотаСКО = Ложь;
	
	ДокументооборотСКОВызовСервера.ПриНажатииНаКнопкуОтправкиВКонтролирующийОрган(ОрганизацияОтчета, КонтролирующийОрган, НастроенОбменВУниверсальномФормате, УчетнаяЗаписьПредназначенаДляДокументооборотаСКО);
	
	Если НЕ НастроенОбменВУниверсальномФормате Тогда
		ЭлектронныйДокументооборотСКонтролирующимиОрганамиКлиент.ПоказатьФормуПредложениеОформитьЗаявлениеНаПодключение(ОрганизацияОтчета);
		Возврат;
	Иначе
		Если УчетнаяЗаписьПредназначенаДляДокументооборотаСКО = Неопределено Тогда
			ПоказатьПредупреждение(, "Недостаточно прав для использования модуля документооборота!");
			Возврат;
			
		ИначеЕсли УчетнаяЗаписьПредназначенаДляДокументооборотаСКО = Ложь Тогда
			
			Если КонтролирующийОрган = "ФНС" Тогда
				ПоказатьПредупреждение(, "Учетная запись документооборота, сопоставленная организации, не предназначена для взаимодействия с ФНС.");
			ИначеЕсли КонтролирующийОрган = "ПФР" Тогда
				ПоказатьПредупреждение(, "Учетная запись документооборота, сопоставленная организации, не предназначена для взаимодействия с ПФР.");
			ИначеЕсли КонтролирующийОрган = "ФСГС" Тогда
				ПоказатьПредупреждение(, "Учетная запись документооборота, сопоставленная организации, не предназначена для взаимодействия с Росстатом.");
			КонецЕсли;
			
			Возврат;
			
		КонецЕсли;
	КонецЕсли;
	
	ДополнительныеПараметры = Новый Структура("Форма, КонтролирующийОрган, СсылкаНаОтчет, ЭтоОтправкаИзФормыОтчетность, ОрганизацияОтчета, ЭтоУведомлениеФНС", Форма, КонтролирующийОрган, СсылкаНаОтчет, ЭтоОтправкаИзФормыОтчетность, ОрганизацияОтчета, ЭтоУведомлениеФНС);
	ОписаниеОповещения = Новый ОписаниеОповещения("ОтправкаВКонтролирующийОрганПослеСохраненияЗавершение", ДокументооборотСКОКлиент, ДополнительныеПараметры);
	ДокументооборотСКОКлиент.ПолучитьКонтекстЭДО(ОписаниеОповещения);
	
КонецПроцедуры

Процедура ОтправкаВКонтролирующийОрганЭтоУведомлениеПослеИнициализации(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат Тогда
		Форма = ДополнительныеПараметры.Форма;
		СсылкаНаОтчет = ДополнительныеПараметры.СсылкаНаОтчет;
		КонтекстЭДОКлиент = ДополнительныеПараметры.КонтекстЭДОКлиент;
		
		ОписаниеОповещения = Новый ОписаниеОповещения("ПослеОтправкиУведомленияФНСЗавершение", ДокументооборотСКОКлиент, ДополнительныеПараметры);
		КонтекстЭДОКлиент.ОтправкаУведомлениеФНС(СсылкаНаОтчет, Форма.УникальныйИдентификатор, ОписаниеОповещения);
	КонецЕсли;
	
КонецПроцедуры

Процедура ПослеОтправкиУведомленияФНСЗавершение(РезультатОтправки, ДополнительныеПараметры) Экспорт
	
	КонтекстЭДОКлиент = ДополнительныеПараметры.КонтекстЭДОКлиент;
	ЭтоОтправкаИзФормыОтчетность = ДополнительныеПараметры.ЭтоОтправкаИзФормыОтчетность;
	Форма = ДополнительныеПараметры.Форма;
	КонтролирующийОрган = ДополнительныеПараметры.КонтролирующийОрган;
	СсылкаНаОтчет = ДополнительныеПараметры.СсылкаНаОтчет;
	
	КонтекстЭДОКлиент.ПредупредитьЕслиСтатусОтправкиВКонверте(СсылкаНаОтчет, "уведомление");
	
	Если НЕ ЭтоОтправкаИзФормыОтчетность Тогда
		Если РезультатОтправки Тогда
			ЭлектронныйДокументооборотСКонтролирующимиОрганамиКлиентСервер.ОбновитьПанельСостоянияОтправкиВРегламентированномОтчете(Форма, КонтролирующийОрган);
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

Процедура ОтправкаВКонтролирующийОрганПослеСохраненияЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	СсылкаНаОтчет = ДополнительныеПараметры.СсылкаНаОтчет;
	КонтекстЭДОКлиент = Результат.КонтекстЭДО;
	ДополнительныеПараметры.Вставить("КонтекстЭДОКлиент", КонтекстЭДОКлиент);
	
	ПараметрыФормы = Новый Структура("СсылкаНаОтчет", СсылкаНаОтчет);
	ОписаниеОповещения = Новый ОписаниеОповещения("ОтправкаВКонтролирующийОрганПодтверждениеОтправкиОтчетаЗавершение", ДокументооборотСКОКлиент, ДополнительныеПараметры);
	// при отправке из списка подтверждение запрашивается перед запуском отправки для предотвращения попадания сообщений в диалог подтверждения
	Если ДополнительныеПараметры.Форма = Неопределено ИЛИ ДополнительныеПараметры.Форма.ИмяФормы <> "ОбщаяФорма.РегламентированнаяОтчетность" Тогда
		ОткрытьФорму(КонтекстЭДОКлиент.ПутьКОбъекту + ".Форма.ПодтверждениеОтправкиОтчета", ПараметрыФормы,,,,, ОписаниеОповещения, РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
	Иначе
		ВыполнитьОбработкуОповещения(ОписаниеОповещения, КодВозвратаДиалога.ОК);
	КонецЕсли;
	
КонецПроцедуры

Процедура ОтправкаВКонтролирующийОрганПодтверждениеОтправкиОтчетаЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат <> КодВозвратаДиалога.ОК Тогда
		Возврат;
	КонецЕсли;
	
	ОрганизацияОтчета = ДополнительныеПараметры.ОрганизацияОтчета;
	ЭтоУведомлениеФНС = ДополнительныеПараметры.ЭтоУведомлениеФНС;
	КонтекстЭДОКлиент = ДополнительныеПараметры.КонтекстЭДОКлиент;
	
	Если ЭтоУведомлениеФНС Тогда
		ОписаниеОповещения = Новый ОписаниеОповещения("ОтправкаВКонтролирующийОрганЭтоУведомлениеПослеИнициализации", ДокументооборотСКОКлиент, ДополнительныеПараметры);
	Иначе
		ОписаниеОповещения = Новый ОписаниеОповещения("ОтправкаВКонтролирующийОрганПослеИнициализации", ДокументооборотСКОКлиент, ДополнительныеПараметры);
	КонецЕсли;
	
	УчетнаяЗапись = КонтекстЭДОКлиент.УчетнаяЗаписьОрганизации(ОрганизацияОтчета);
	//Обновление рег. Отчетности на бух. Корп 3.0.36.18
	//ЭтоЭлектроннаяПодписьВМоделиСервиса = ЭлектроннаяПодписьВМоделиСервисаВызовСервера.РеквизитыУчетнойЗаписи(УчетнаяЗапись).ЭлектроннаяПодписьВМоделиСервиса;
	ЭтоЭлектроннаяПодписьВМоделиСервиса = Ложь;
	Если НЕ ЭтоЭлектроннаяПодписьВМоделиСервиса Тогда
		// Проверим возможность подключения ВК
		ИнициализацияВК(ОписаниеОповещения);
	//Иначе
	//	КриптосервисВМоделиСервисаКлиент.ИнициализацияСАвторизацией(УчетнаяЗапись, , ОписаниеОповещения);
	КонецЕсли;
	//<=	
	
КонецПроцедуры

Процедура ОтправкаВКонтролирующийОрганПослеИнициализации(Результат, ДополнительныеПараметры) Экспорт
	
	СсылкаНаОтчет 		= ДополнительныеПараметры.СсылкаНаОтчет;
	КонтролирующийОрган = ДополнительныеПараметры.КонтролирующийОрган;
	КонтекстЭДОКлиент 	= ДополнительныеПараметры.КонтекстЭДОКлиент;
	
	Если Результат Тогда
		
		ОписаниеОповещения = Новый ОписаниеОповещения("ОтправкаВКонтролирующийОрганПослеОтправки", ДокументооборотСКОКлиент, ДополнительныеПараметры);
		
		// регистрируем заявку на отправку
		Если КонтролирующийОрган = "ФНС" Тогда
			КонтекстЭДОКлиент.ОтправкаРегламентированногоОтчетаВФНС(СсылкаНаОтчет, ОписаниеОповещения);
		ИначеЕсли КонтролирующийОрган = "ФСГС" Тогда
			КонтекстЭДОКлиент.ОтправкаРегламентированногоОтчетаВФСГС(СсылкаНаОтчет, ОписаниеОповещения);
		Иначе
			КонтекстЭДОКлиент.ОтправкаРегламентированногоОтчетаВПФР(СсылкаНаОтчет, ОписаниеОповещения);
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ОтправкаВКонтролирующийОрганПослеОтправки(РезультатОтправки, ДополнительныеПараметры) Экспорт
	
	ЭтоОтправкаИзФормыОтчетность = ДополнительныеПараметры.ЭтоОтправкаИзФормыОтчетность;
	Форма = ДополнительныеПараметры.Форма;
	КонтролирующийОрган = ДополнительныеПараметры.КонтролирующийОрган;
	СсылкаНаОтчет = ДополнительныеПараметры.СсылкаНаОтчет;
	ОрганизацияОтчета = ДополнительныеПараметры.ОрганизацияОтчета;
	КонтекстЭДОКлиент = ДополнительныеПараметры.КонтекстЭДОКлиент;
	
	КонтекстЭДОКлиент.ПредупредитьЕслиСтатусОтправкиВКонверте(СсылкаНаОтчет, "отчет");
	
	Если НЕ ЭтоОтправкаИзФормыОтчетность Тогда
		Если РезультатОтправки Тогда
			ЭлектронныйДокументооборотСКонтролирующимиОрганамиКлиентСервер.ОбновитьПанельСостоянияОтправкиВРегламентированномОтчете(Форма, КонтролирующийОрган);
		КонецЕсли;
	КонецЕсли;
	
	ПараметрыОповещения = Новый Структура(); 
	ПараметрыОповещения.Вставить("Ссылка", СсылкаНаОтчет);
	ПараметрыОповещения.Вставить("Организация", ОрганизацияОтчета);
	Оповестить("Завершение отправки в контролирующий орган", ПараметрыОповещения, );
	
КонецПроцедуры

Процедура ПроверитьВИнтернете(Форма, КонтролирующийОрган = "ФНС") Экспорт
	
	СсылкаНаОтчет = ЭлектронныйДокументооборотСКонтролирующимиОрганамиКлиентСервер.СсылкаНаОтчетПоФорме(Форма);
	ТипЗнчСсылкаНаОтчет = ТипЗнч(СсылкаНаОтчет);
	ИмяДокументаУведомлениеОКонтролируемыхСделках 	= ЭлектронныйДокументооборотСКонтролирующимиОрганамиКлиентСерверПереопределяемый.ИмяОбъектаМетаданных("УведомлениеОКонтролируемыхСделках");
	ИмяДокументаИсходящееУведомлениеФНС 			= "УведомлениеОСпецрежимахНалогообложения";
	
	ИмяДокументаЗаявлениеОВвозеТоваров 	= ЭлектронныйДокументооборотСКонтролирующимиОрганамиКлиентСерверПереопределяемый.ИмяОбъектаМетаданных("ЗаявлениеОВвозеТоваров");
	
	Если ИмяДокументаЗаявлениеОВвозеТоваров <> Неопределено И ТипЗнчСсылкаНаОтчет = Тип("ДокументСсылка." + ИмяДокументаЗаявлениеОВвозеТоваров) Тогда
		ЭтоЗаявлениеОВвозе = Истина;
	Иначе
		ЭтоЗаявлениеОВвозе = Ложь;
	КонецЕсли;
	
	Если (ИмяДокументаУведомлениеОКонтролируемыхСделках <> Неопределено И ТипЗнчСсылкаНаОтчет = Тип("ДокументСсылка." + ИмяДокументаУведомлениеОКонтролируемыхСделках))
		ИЛИ (ИмяДокументаИсходящееУведомлениеФНС <> Неопределено И ТипЗнчСсылкаНаОтчет = Тип("ДокументСсылка." + ИмяДокументаИсходящееУведомлениеФНС)) Тогда
		ЭтоУведомлениеФНС = Истина;
	Иначе
		ЭтоУведомлениеФНС = Ложь;
	КонецЕсли;
	
	Если ТипЗнчСсылкаНаОтчет = Тип("ДокументСсылка.РегламентированныйОтчет")
		ИЛИ ТипЗнчСсылкаНаОтчет = Тип("Неопределено") Тогда
		
		// отправляем только из записанной формы
		Если Форма.Модифицированность Тогда
			
			ДополнительныеПараметры = Новый Структура("Форма, КонтролирующийОрган", Форма, КонтролирующийОрган);
			ОписаниеОповещения = Новый ОписаниеОповещения("ПроверитьВИнтернетеЗавершение", ДокументооборотСКОКлиент, ДополнительныеПараметры);
			
			Форма.СохранитьНаКлиенте(, ОписаниеОповещения);
			
		Иначе
			ПроверитьВИнтернетеПослеСохранения(Форма, КонтролирующийОрган, СсылкаНаОтчет)
		КонецЕсли;
		
	ИначеЕсли ЭтоУведомлениеФНС Тогда
		
		Если НЕ ЗначениеЗаполнено(СсылкаНаОтчет) ИЛИ Форма.Модифицированность Тогда
			ПоказатьПредупреждение(,ВернутьСтр("ru = 'Перед проверкой необходимо записать уведомление.'"));
			Возврат;
		КонецЕсли;
		
		ПроверитьВИнтернетеПослеСохранения(Форма, КонтролирующийОрган, СсылкаНаОтчет)

	ИначеЕсли ЭтоЗаявлениеОВвозе Тогда
		
		Если НЕ ЗначениеЗаполнено(СсылкаНаОтчет) ИЛИ Форма.Модифицированность Тогда
			ПоказатьПредупреждение(,ВернутьСтр("ru = 'Перед проверкой необходимо записать заявление.'"));
			Возврат;
		КонецЕсли;
		
		ПроверитьВИнтернетеПослеСохранения(Форма, КонтролирующийОрган, СсылкаНаОтчет)
		
	Иначе // все, кроме документа РегламентированныйОтчет
		
		//Если Форма.Модифицированность Тогда
		//	Предупреждение(ВернутьСтр("ru = 'Необходимо записать отчет перед проверкой.'"));
		//	Возврат;
		//КонецЕсли;
		ПроверитьВИнтернетеПослеСохранения(Форма, КонтролирующийОрган, СсылкаНаОтчет)
	
	КонецЕсли;
	
КонецПроцедуры

Процедура ПроверитьВИнтернетеЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	Форма = ДополнительныеПараметры.Форма;
	КонтролирующийОрган = ДополнительныеПараметры.КонтролирующийОрган;
	СсылкаНаОтчет = ЭлектронныйДокументооборотСКонтролирующимиОрганамиКлиентСервер.СсылкаНаОтчетПоФорме(Форма);
	
	ПроверитьВИнтернетеПослеСохранения(Форма, КонтролирующийОрган, СсылкаНаОтчет)
	
КонецПроцедуры

Процедура ПроверитьВИнтернетеПослеСохранения(Форма, КонтролирующийОрган, СсылкаНаОтчет)
		
	ДополнительныеПараметры = Новый Структура;
	ДополнительныеПараметры.Вставить("Форма", Форма);
	ДополнительныеПараметры.Вставить("КонтролирующийОрган", КонтролирующийОрган);
	ДополнительныеПараметры.Вставить("СсылкаНаОтчет", СсылкаНаОтчет);
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ПроверитьВИнтернетеПослеПолученияКонтекста", ДокументооборотСКОКлиент, ДополнительныеПараметры);
	ДокументооборотСКОКлиент.ПолучитьКонтекстЭДО(ОписаниеОповещения);
	
КонецПроцедуры

Процедура ПроверитьВИнтернетеПослеПолученияКонтекста(Результат, ДополнительныеПараметры) Экспорт
	
	СсылкаНаОтчет = ДополнительныеПараметры.СсылкаНаОтчет;
	КонтролирующийОрган = ДополнительныеПараметры.КонтролирующийОрган;
	Форма = ДополнительныеПараметры.Форма;
	КонтекстЭДОКлиент = Результат.КонтекстЭДО;
	
	Если КонтекстЭДОКлиент <> Неопределено Тогда
		
		// Проверяем наличие учетной записи
		ОрганизацияОтчета = КонтекстЭДОКлиент.ОрганизацияОтчетаДляОнлайнПроверки(СсылкаНаОтчет);
		УчетнаяЗаписьОрганизации = КонтекстЭДОКлиент.УчетнаяЗаписьОрганизации(ОрганизацияОтчета);
		
		Если НЕ ЗначениеЗаполнено(УчетнаяЗаписьОрганизации) Тогда
			ЭлектронныйДокументооборотСКонтролирующимиОрганамиКлиент.ПоказатьФормуПредложениеОформитьЗаявлениеНаПодключение(ОрганизацияОтчета);
			Возврат;
		КонецЕсли;
		
		КонтекстЭДОКлиент.ПроверитьОтчетСИспользованиемСервисаОнлайнПроверки(СсылкаНаОтчет, КонтролирующийОрган, Истина, Форма);
	Иначе
		ПоказатьПредупреждение(,ВернутьСтр("ru = 'Недостаточно прав для использования методов электронного документооборота с контролирующими органами.'"));
	КонецЕсли;
	
КонецПроцедуры

Процедура ПроверитьВИнтернетеПоСсылке(Ссылка, КонтролирующийОрган = "ФНС") Экспорт
	
	ТипЗнчСсылка = ТипЗнч(Ссылка);
	ИмяДокументаУведомлениеОКонтролируемыхСделках 	= ЭлектронныйДокументооборотСКонтролирующимиОрганамиКлиентСерверПереопределяемый.ИмяОбъектаМетаданных("УведомлениеОКонтролируемыхСделках");
	ИмяДокументаИсходящееУведомлениеФНС 			= "УведомлениеОСпецрежимахНалогообложения";
	
	Если (ИмяДокументаУведомлениеОКонтролируемыхСделках <> Неопределено И ТипЗнчСсылка = Тип("ДокументСсылка." + ИмяДокументаУведомлениеОКонтролируемыхСделках))
	ИЛИ (ИмяДокументаИсходящееУведомлениеФНС <> Неопределено И ТипЗнчСсылка = Тип("ДокументСсылка." + ИмяДокументаИсходящееУведомлениеФНС)) Тогда
		ЭтоУведомлениеФНС = Истина;
	Иначе
		ЭтоУведомлениеФНС = Ложь;
	КонецЕсли;
	
	ДополнительныеПараметры = Новый Структура("Ссылка, КонтролирующийОрган", Ссылка, КонтролирующийОрган);
	ОписаниеОповещения = Новый ОписаниеОповещения("ПроверитьВИнтернетеПоСсылкеЗавершение", ДокументооборотСКОКлиент, ДополнительныеПараметры);
	ДокументооборотСКОКлиент.ПолучитьКонтекстЭДО(ОписаниеОповещения);
	
КонецПроцедуры

Процедура ПроверитьВИнтернетеПоСсылкеЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	Ссылка = ДополнительныеПараметры.Ссылка;
	КонтролирующийОрган = ДополнительныеПараметры.КонтролирующийОрган;
	КонтекстЭДОКлиент = Результат.КонтекстЭДО;
	
	Если КонтекстЭДОКлиент <> Неопределено Тогда
		КонтекстЭДОКлиент.ПроверитьОтчетСИспользованиемСервисаОнлайнПроверки(Ссылка, КонтролирующийОрган);
	Иначе
		ПоказатьПредупреждение(,ВернутьСтр("ru = 'Недостаточно прав для использования методов электронного документооборота с контролирующими органами.'"));
	КонецЕсли;
	
КонецПроцедуры

Процедура ПослеЗапускаСистемы() Экспорт
	
	Если ПользователиКлиентСервер.ЭтоСеансВнешнегоПользователя() Тогда
		Возврат;
	КонецЕсли;
	
	ПараметрыРаботыКлиентаПриЗапуске = СтандартныеПодсистемыКлиентПовтИсп.ПараметрыРаботыКлиентаПриЗапуске();
	ТекущемуПользователюЭДОДоступен = ПараметрыРаботыКлиентаПриЗапуске.ДокументооборотСКонтролирующимиОрганами_ТекущемуПользователюЭДОДоступен;
	ТекущемуПользователюАОДоступен = ПараметрыРаботыКлиентаПриЗапуске.ДокументооборотСКонтролирующимиОрганами_ТекущемуПользователюАОДоступен;
	ВыбранныйCSPИзВременныхНастроек = ПараметрыРаботыКлиентаПриЗапуске.ДокументооборотСКонтролирующимиОрганами_ВыбранныйCSPИзВременныхНастроек;
	ИспользованиеЭлектроннойПодписиВМоделиСервисаВозможно = ПараметрыРаботыКлиентаПриЗапуске.ДокументооборотСКонтролирующимиОрганами_ИспользованиеЭлектроннойПодписиВМоделиСервисаВозможно;
	
	Если ТекущемуПользователюЭДОДоступен Тогда
		ПодключитьОбработчикОжидания("ПолучитьИнформациюОВходящихСообщенияхДляПользователяЭДО", 300, Истина);
	КонецЕсли;
	ПодключениеОбработчикаОжиданияАвтообмена(Истина, ТекущемуПользователюАОДоступен);
	ОткрытьМастерПодключенияК1СОтчетности(ВыбранныйCSPИзВременныхНастроек);
	Если ТекущемуПользователюЭДОДоступен Тогда
		ПодключитьОбработчикОжидания("ПредупредитьОбИстеченииСертификатов", 900, Истина);
	КонецЕсли;
	
	// Подключение обработчиков ожидания Электронной подписи в модели сервиса
	// при условии, что использование подсистемы возможно.
	Если ИспользованиеЭлектроннойПодписиВМоделиСервисаВозможно Тогда
		МодульЭлектроннаяПодписьВМоделиСервисаКлиент = ОбщегоНазначенияКлиентСервер.ОбщийМодуль("ЭлектроннаяПодписьВМоделиСервисаКлиент");
		МодульЭлектроннаяПодписьВМоделиСервисаКлиент.ПодключитьОбработчикПроверкиЗаявлений(10, Истина);
	КонецЕсли;
	
КонецПроцедуры

Процедура ПодключениеОбработчикаОжиданияАвтообмена(Подключать = Истина, ТекущемуПользователюАОДоступен = Неопределено) Экспорт
	
	Если Подключать Тогда
		// проверяем, является ли текущий пользователь пользователем ДО
		// проверяем отключение автообмена на уровне учетной записи документооборота
		Если ТекущемуПользователюАОДоступен = Истина ИЛИ (ТекущемуПользователюАОДоступен = Неопределено
			И ДокументооборотСКОВызовСервера.ТекущемуПользователюАОДоступен()) Тогда
			
			// если проверки пройдены, определяем интервал выполнения
			Интервал = ПолучитьИнтервалВыполнения();
			
			Если Интервал = Неопределено Тогда
				Возврат;
			КонецЕсли;
			
			ПодключитьОбработчикОжидания("ПолучитьИнформациюОВходящихСообщениях", Интервал);
			
		КонецЕсли;
		
	Иначе
		ОтключитьОбработчикОжидания("ПолучитьИнформациюОВходящихСообщениях");
	КонецЕсли;
	
КонецПроцедуры

Функция ПолучитьИнтервалВыполнения()
	
	// в разделенном режиме получить РЗ вне Области данных.
	Результат = 60*60*3; // 3(три) часа
	Возврат Результат;
	
КонецФункции

Процедура ОткрытьМастерПодключенияК1СОтчетности(СохраненныеНастройки)
	
	// Если пользователь в мастере подключения остановился на шаге установки криптопровайдеров (шаг 2)
	// и после установки криптопровайдера перезагрузил компьютер, то необходимо открыть мастер для продолжения
	// подключения к 1С-Отчетности
	Если СохраненныеНастройки <> Неопределено Тогда
		
		#Если ВебКлиент Тогда
			Если НЕ ЭлектронныйДокументооборотСКонтролирующимиОрганамиКлиент.ЭтоРазрешенныйБраузер(Ложь) Тогда
				ЭлектронныйДокументооборотСКонтролирующимиОрганамиВызовСервера.УдалитьВыборCSPИзВременныхНастроек();
				Возврат;
			КонецЕсли;
		#КонецЕсли
		
		ДополнительныеПараметры = Новый Структура("СохраненныеНастройки", СохраненныеНастройки);
		ОписаниеОповещения = Новый ОписаниеОповещения("ОткрытьМастерПодключенияК1СОтчетностиЗавершение", ДокументооборотСКОКлиент, ДополнительныеПараметры);
		ДокументооборотСКОКлиент.ПолучитьКонтекстЭДО(ОписаниеОповещения);
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ОткрытьМастерПодключенияК1СОтчетностиЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	КонтекстЭДОКлиент = Результат.КонтекстЭДО;
	СохраненныеНастройки = ДополнительныеПараметры.СохраненныеНастройки;
	
	Если КонтекстЭДОКлиент <> Неопределено Тогда
		
		Если ТипЗнч(СохраненныеНастройки) = Тип("СправочникСсылка.Организации") Тогда
			ПараметрыФормы = Новый Структура();
			ПараметрыФормы.Вставить("Организация", СохраненныеНастройки);
			ОткрытьФорму(КонтекстЭДОКлиент.ПутьКОбъекту + ".Форма.МастерФормированияЗаявкиНаПодключение", ПараметрыФормы);
		Иначе
			ОткрытьФорму(КонтекстЭДОКлиент.ПутьКОбъекту + ".Форма.МастерФормированияЗаявкиНаПодключение");
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ПолучитьИнформациюОВходящихСообщенияхЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	КонтекстЭДОКлиент = Результат.КонтекстЭДО;
	
	Если КонтекстЭДОКлиент = Неопределено Тогда
		Возврат;
	КонецЕсли;
	КонтекстЭДОКлиент.ПолучитьИОбработатьВходящиеКлиент();
	
КонецПроцедуры

Процедура ПолучитьИнформациюОВходящихСообщенияхДляПользователяЭДОЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	КонтекстЭДОКлиент = Результат.КонтекстЭДО;
	
	Если КонтекстЭДОКлиент = Неопределено Тогда
		Возврат;
	КонецЕсли;
	КонтекстЭДОКлиент.ПолучитьИОбработатьВходящиеКлиент();
	
КонецПроцедуры

Процедура ПредупредитьОбИстеченииСертификатовЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	КонтекстЭДОКлиент = Результат.КонтекстЭДО;
	
	Если КонтекстЭДОКлиент = Неопределено Тогда
		Возврат;
	КонецЕсли;
	КонтекстЭДОКлиент.ПредупредитьОбИстеченииСертификатовКлиент();
	
КонецПроцедуры

Процедура СоздатьЭлектронноеПредставлениеРегламентированныхОтчетовИзФайлов(Файлы, Адрес) Экспорт
	
	МассивФайлов = Новый Массив;
	Если ТипЗнч(Файлы) = Тип("Файл") Тогда
		МассивФайлов.Добавить(Файлы.ПолноеИмя);
	ИначеЕсли ТипЗнч(Файлы) = Тип("Массив") Тогда
		Для Каждого Значение Из Файлы Цикл
			Если ТипЗнч(Значение) = Тип("Файл") Тогда
				МассивФайлов.Добавить(Значение.ПолноеИмя);
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
	Если МассивФайлов.Количество() > 0 Тогда
		ФайлыИмпорта = СтрСоединить(МассивФайлов, Символы.ПС);
				
		ДополнительныеПараметры = Новый Структура("Адрес, ФайлыИмпорта", Адрес, ФайлыИмпорта);
		ОписаниеОповещения = Новый ОписаниеОповещения("СоздатьЭлектронноеПредставлениеРегламентированныхОтчетовИзФайловЗавершение", ДокументооборотСКОКлиент, ДополнительныеПараметры);
		ДокументооборотСКОКлиент.ПолучитьКонтекстЭДО(ОписаниеОповещения);
	КонецЕсли;
	
КонецПроцедуры

Процедура СоздатьЭлектронноеПредставлениеРегламентированныхОтчетовИзФайловЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	КонтекстЭДОКлиент = Результат.КонтекстЭДО;
	
	КонтекстЭДОКлиент.ПолучениеФайловДляИмпортаНачало(ДополнительныеПараметры.Адрес, ДополнительныеПараметры.ФайлыИмпорта);
		
КонецПроцедуры

// Инициализация ВК

Процедура ИнициализацияВК(ВыполняемоеОповещение = Неопределено) Экспорт
	
	ПутьВК = ЭлектронныйДокументооборотСКонтролирующимиОрганамиВызовСервера.ПолучитьПутьВК();
	
	Если Инициализация_ПодключитьВК(ПутьВК) Тогда
		
		ОписаниеОповещения = Новый ОписаниеОповещения("ИнициализацияВК_УстановитьРасширениеРаботыСФайламиПродолжение", ДокументооборотСКОКлиент, ВыполняемоеОповещение);
		ВыполнитьОбработкуОповещения(ОписаниеОповещения, Истина);
		
	Иначе
		
		ДополнительныеПараметры = Новый Структура("ВыполняемоеОповещение, ПутьВК", ВыполняемоеОповещение, ПутьВК);
		ОписаниеОповещения = Новый ОписаниеОповещения("Инициализация_ПодключитьИУстановитьВКЗавершение", ДокументооборотСКОКлиент, ДополнительныеПараметры);
		Инициализация_УстановитьВК(ПутьВК, ОписаниеОповещения)
		
	КонецЕсли;

КонецПроцедуры

Функция Инициализация_ПодключитьВК(ПутьВК) Экспорт
	
	Попытка
		КодВозврата = ПодключитьВнешнююКомпоненту(ПутьВК, "ЭДОNative");
	Исключение
		КодВозврата = Ложь;
	КонецПопытки;
	
	Возврат КодВозврата;
	
КонецФункции

Процедура Инициализация_УстановитьВК(ПутьВК, ВыполняемоеОповещение)
	
	ВебБраузер = РегламентированнаяОтчетностьКлиент.ВебБраузер();
	
	ВЭтомСеансеОткрывалиОкноУстановки = Ложь;
	
	Если ВебБраузер = "FIREFOX" Тогда
		
		ДополнительныеПараметры = Новый Структура("ВыполняемоеОповещение", ВыполняемоеОповещение);
		ОписаниеОповещения = Новый ОписаниеОповещения("Инициализация_УстановитьВКвFIREFOXЗавершение", ДокументооборотСКОКлиент, ДополнительныеПараметры);
		ЭлектронныйДокументооборотСКонтролирующимиОрганамиКлиент.ОткрытьФормуУстановкиКомпонентыВFIREFOX(ПутьВК, ОписаниеОповещения);
		
	Иначе
		
		Попытка
			ДополнительныеПараметры = Новый Структура("ВыполняемоеОповещение", ВыполняемоеОповещение);
			ОписаниеОповещения = Новый ОписаниеОповещения("Инициализация_УстановитьВКЗавершение", ДокументооборотСКОКлиент, ДополнительныеПараметры);
			НачатьУстановкуВнешнейКомпоненты(ОписаниеОповещения, ПутьВК);
		Исключение
			КомпонентаУстановлена = Ложь;
			ТекстСообщения = ВернутьСтр("ru='Не удалось установить внешнюю компоненту для работы с криптографией.'");
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
			ВыполнитьОбработкуОповещения(ВыполняемоеОповещение, КомпонентаУстановлена);
		КонецПопытки;
		
	КонецЕсли;
	
КонецПроцедуры

Процедура Инициализация_УстановитьВКвFIREFOXЗавершение(ЗавершениеДиалогаУстановки, ДополнительныеПараметры) Экспорт
	
	ВыполняемоеОповещение = ДополнительныеПараметры.ВыполняемоеОповещение;
	
	// в FIREFOX установка завершается при следующем открытии браузера
	Если ВыполняемоеОповещение <> Неопределено Тогда
		ОписаниеОповещения = Новый ОписаниеОповещения("ИнициализацияВК_УстановитьРасширениеРаботыСФайламиПродолжение", ДокументооборотСКОКлиент, ВыполняемоеОповещение);
		ВыполнитьОбработкуОповещения(ОписаниеОповещения, Ложь);
	КонецЕсли;
	
КонецПроцедуры

Процедура Инициализация_УстановитьВКЗавершение(ДополнительныеПараметры) Экспорт
	
	ВыполняемоеОповещение = ДополнительныеПараметры.ВыполняемоеОповещение;
	КомпонентаУстановлена = Истина;
	
	ВыполнитьОбработкуОповещения(ВыполняемоеОповещение, КомпонентаУстановлена);
	
КонецПроцедуры

Процедура Инициализация_ПодключитьИУстановитьВКЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	ВыполняемоеОповещение = ДополнительныеПараметры.ВыполняемоеОповещение;
	ПутьВК = ДополнительныеПараметры.ПутьВК;
	
	Если Результат Тогда
		Если Инициализация_ПодключитьВК(ПутьВК) Тогда
			КомпонентаУстановлена = Истина;
		Иначе
			КомпонентаУстановлена = Ложь;
		КонецЕсли
	Иначе
		КомпонентаУстановлена = Ложь;
	КонецЕсли;
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ИнициализацияВК_УстановитьРасширениеРаботыСФайламиПродолжение", ДокументооборотСКОКлиент, ВыполняемоеОповещение);
	ВыполнитьОбработкуОповещения(ОписаниеОповещения, КомпонентаУстановлена);
	
КонецПроцедуры

Процедура ИнициализацияВК_УстановитьРасширениеРаботыСФайламиПродолжение(РезультатИнициализацииВК, ВыполняемоеОповещение) Экспорт
	
	Если ПодключитьРасширениеРаботыСФайлами() Тогда
		Если ВыполняемоеОповещение <> Неопределено Тогда
			ВыполнитьОбработкуОповещения(ВыполняемоеОповещение, РезультатИнициализацииВК);
		КонецЕсли;
	Иначе
		ДополнительныеПараметры = Новый Структура("РезультатИнициализацииВК, ВыполняемоеОповещение", РезультатИнициализацииВК, ВыполняемоеОповещение);
		ОписаниеОповещения = Новый ОписаниеОповещения("ИнициализацияВК_УстановитьРасширениеРаботыСФайламиЗавершение", ДокументооборотСКОКлиент, ДополнительныеПараметры);
		НачатьУстановкуРасширенияРаботыСФайлами(ОписаниеОповещения);
	КонецЕсли;
	
КонецПроцедуры

Процедура ИнициализацияВК_УстановитьРасширениеРаботыСФайламиЗавершение(ДополнительныеПараметры) Экспорт
	
	РезультатИнициализацииВК = ДополнительныеПараметры.РезультатИнициализацииВК;
	ВыполняемоеОповещение = ДополнительныеПараметры.ВыполняемоеОповещение;
	
	// Всегда продолжаем работу, даже если пользователь отказался от установки расширения работы с файлами.
	Если ВыполняемоеОповещение <> Неопределено Тогда
		ВыполнитьОбработкуОповещения(ВыполняемоеОповещение, РезультатИнициализацииВК);
	КонецЕсли;
	
КонецПроцедуры