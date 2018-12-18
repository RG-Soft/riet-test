////////////////////////////////////////////////////////////////////////////////
// ПРОГРАММНЫЙ ИНТЕРФЕЙС

// Только для внутреннего использования
Функция ПрофильНастроекЭДОУникален() Экспорт
	
	Если ПометкаУдаления Тогда
		Возврат Истина;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ РАЗЛИЧНЫЕ
	|	ПрофилиНастроекЭДО.Ссылка КАК ПрофильНастроекЭДО
	|ИЗ
	|	Справочник.ПрофилиНастроекЭДО КАК ПрофилиНастроекЭДО
	|ГДЕ
	|	ПрофилиНастроекЭДО.ссылка <> &Ссылка
	|	И ПрофилиНастроекЭДО.СпособОбменаЭД = &СпособОбменаЭД
	|			И ПрофилиНастроекЭДО.Организация = &Организация
	|					И ПрофилиНастроекЭДО.ИдентификаторОрганизации = &ИдентификаторОрганизации
	|	И Не ПрофилиНастроекЭДО.ПометкаУдаления";
	
	Запрос.УстановитьПараметр("ИдентификаторОрганизации", ЭтотОбъект.ИдентификаторОрганизации);
	Запрос.УстановитьПараметр("Организация",              ЭтотОбъект.Организация);
	Запрос.УстановитьПараметр("Ссылка",                   ЭтотОбъект.Ссылка);
	Запрос.УстановитьПараметр("СпособОбменаЭД",           ЭтотОбъект.СпособОбменаЭД);
	Результат = Запрос.Выполнить();
	ТекущийПрофильНастроекУникален = Результат.Пустой();
	
	Если Не ТекущийПрофильНастроекУникален Тогда
		ШаблонСообщения = ВернутьСтр("ru = 'В информационной базе уже существует профиль настроек с реквизитами:
		|Организация - %1;
		|Идентификатор организации - %2;
		|Способ обмена - %3;'");
		Выборка = Результат.Выбрать();
		Выборка.Следующий();
		ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
														ШаблонСообщения,
														ЭтотОбъект.Организация,
														ЭтотОбъект.ИдентификаторОрганизации,
														ЭтотОбъект.СпособОбменаЭД);
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстОшибки);
	КонецЕсли;
	
	Возврат ТекущийПрофильНастроекУникален;
	
КонецФункции

// Только для внутреннего использования
Процедура ПометитьНаУдалениеСвязанныеНастройкиЭДО(ПрофильНастроекЭДО, Отказ) Экспорт
	
	// Замена табличной части в связанных настройках ЭДО.
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	СоглашенияОбИспользованииЭД.ИдентификаторКонтрагента,
	|	СоглашенияОбИспользованииЭД.Ссылка КАК НастройкаЭДО
	|ИЗ
	|	Справочник.СоглашенияОбИспользованииЭД КАК СоглашенияОбИспользованииЭД
	|ГДЕ
	|	НЕ СоглашенияОбИспользованииЭД.РасширенныйРежимНастройкиСоглашения
	|	И СоглашенияОбИспользованииЭД.ПометкаУдаления = &ПометкаУдаления
	|	И СоглашенияОбИспользованииЭД.ПрофильНастроекЭДО = &ПрофильНастроекЭДО";
	
	Запрос.УстановитьПараметр("ПрофильНастроекЭДО", ПрофильНастроекЭДО.Ссылка);
	Запрос.УстановитьПараметр("ПометкаУдаления",    Ссылка.ПометкаУдаления);
	
	НачатьТранзакцию();
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		
		Блокировка = Новый БлокировкаДанных;
		ЭлементБлокировки = Блокировка.Добавить("Справочник.СоглашенияОбИспользованииЭД");
		ЭлементБлокировки.УстановитьЗначение("Ссылка", Выборка.НастройкаЭДО);
		Блокировка.Заблокировать();
		
		// Готовится ТЧ для разовой замены в Настройках ЭДО.
		ИсходнаяТаблицаЭД = ПрофильНастроекЭДО.ИсходящиеДокументы.Выгрузить();
		ИсходнаяТаблицаЭД.Колонки.Добавить("ПрофильНастроекЭДО");
		ИсходнаяТаблицаЭД.Колонки.Добавить("СпособОбменаЭД");
		ИсходнаяТаблицаЭД.Колонки.Добавить("ИдентификаторОрганизации");
		ИсходнаяТаблицаЭД.Колонки.Добавить("ИдентификаторКонтрагента");
		
		ИсходнаяТаблицаЭД.ЗаполнитьЗначения(ПрофильНастроекЭДО.Ссылка,                   "ПрофильНастроекЭДО");
		ИсходнаяТаблицаЭД.ЗаполнитьЗначения(ПрофильНастроекЭДО.СпособОбменаЭД,           "СпособОбменаЭД");
		ИсходнаяТаблицаЭД.ЗаполнитьЗначения(ПрофильНастроекЭДО.ИдентификаторОрганизации, "ИдентификаторОрганизации");
		ИсходнаяТаблицаЭД.ЗаполнитьЗначения(Выборка.ИдентификаторКонтрагента,            "ИдентификаторКонтрагента");
		
		ВыбраннаяНастройкаЭДО = Выборка.НастройкаЭДО.ПолучитьОбъект();
		ВыбраннаяНастройкаЭДО.ОбменДанными.Загрузка = Истина;
		ВыбраннаяНастройкаЭДО.ПометкаУдаления = ПометкаУдаления;
		ВыбраннаяНастройкаЭДО.ИдентификаторОрганизации = ПрофильНастроекЭДО.ИдентификаторОрганизации;
		ВыбраннаяНастройкаЭДО.ИсходящиеДокументы.Загрузить(ИсходнаяТаблицаЭД);
		ВыбраннаяНастройкаЭДО.Записать();
		
	КонецЦикла;
	
	ЗафиксироватьТранзакцию();
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	
	Если ПометкаУдаления Тогда
		Возврат;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Организация) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			ЭлектронныеДокументыКлиентСервер.ПолучитьТекстСообщения("Поле", "Заполнение", "Организация"),
			ЭтотОбъект,
			"Организация",
			,
			Отказ);
	КонецЕсли;

	Если СпособОбменаЭД = Перечисления.СпособыОбменаЭД.ЧерезОператораЭДОТакском Тогда
		Если СертификатыПодписейОрганизации.Количество() = 0 Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				ЭлектронныеДокументыКлиентСервер.ПолучитьТекстСообщения("Список", "Заполнение", , , "Сертификаты организации"),
				ЭтотОбъект,
				"СертификатыПодписейОрганизации",
				,
				Отказ);
		КонецЕсли;
		
		Возврат;
	Иначе
		Отбор = Новый Структура;
		Отбор.Вставить("ИспользоватьЭП", Истина);
		
		Если ИсходящиеДокументы.НайтиСтроки(Отбор).Количество() > 0 И СертификатыПодписейОрганизации.Количество() = 0 Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				ЭлектронныеДокументыКлиентСервер.ПолучитьТекстСообщения("Список", "Заполнение", , , "Сертификаты организации"),
				ЭтотОбъект,
				"СертификатыПодписейОрганизации",
				,
				Отказ);
		КонецЕсли;
		
		Возврат;
	КонецЕсли;
	
	Если СпособОбменаЭД = Перечисления.СпособыОбменаЭД.ЧерезFTP Тогда
		Если НЕ ЗначениеЗаполнено(АдресСервера) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				ЭлектронныеДокументыКлиентСервер.ПолучитьТекстСообщения("Поле", "Заполнение", "Адрес сервера"),
				ЭтотОбъект,
				"АдресСервера",
				,
				Отказ);
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

Процедура ПередЗаписью(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	Если Ссылка.ПометкаУдаления <> ПометкаУдаления Тогда
		ПометитьНаУдалениеСвязанныеНастройкиЭДО(ЭтотОбъект, Отказ)
	КонецЕсли;

КонецПроцедуры


