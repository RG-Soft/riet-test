Функция ВедетсяКадровыйУчет() Экспорт
	
	//Обновление рег. Отчетности на бух. Корп 3.0.37.25
	//Возврат Константы.ИспользоватьКадровыйУчет.Получить();
	Возврат Ложь;
	//<=
		
КонецФункции

Функция ДанныеФизическихЛиц(Организация = Неопределено, ФизическиеЛица, ДатаСреза, ФИОКратко = Истина, РезультатТаблично = Ложь) Экспорт
	
	ПоГруппе = Ложь;
	Если ТипЗнч(ФизическиеЛица) = Тип("Массив") Тогда
		ПоГруппе = Истина;
	КонецЕсли;
	
	СписокКадровыхДанных = "Фамилия, Имя, Отчество, Пол, ДатаРождения, МестоРождения, Страна, ФамилияИО, СтраховойНомерПФР, ИНН, ФИОПолные, ДокументВид, ДокументСерия, ДокументНомер, ДокументДатаВыдачи, ДокументКемВыдан, ДокументКодПодразделения, ДокументПредставление";
	
	//КадровыеДанныеФизЛиц = КадровыйУчет.КадровыеДанныеФизическихЛиц(Истина, ФизическиеЛица, СписокКадровыхДанных, ДатаСреза);
	
	Если Организация <> Неопределено Тогда
		КадровыеДанныеСотрудников = Неопределено;
		
	Иначе
		КадровыеДанныеСотрудников = Неопределено;
	КонецЕсли;
	
	Если РезультатТаблично Тогда
		
		ТабРезультат = Новый ТаблицаЗначений();
		ТабРезультат.Колонки.Добавить("ФизическоеЛицо");
		ТабРезультат.Колонки.Добавить("Фамилия");
		ТабРезультат.Колонки.Добавить("Имя");
		ТабРезультат.Колонки.Добавить("Отчество");
		ТабРезультат.Колонки.Добавить("Пол");
		ТабРезультат.Колонки.Добавить("ДатаРождения");
		ТабРезультат.Колонки.Добавить("МестоРождения");
		ТабРезультат.Колонки.Добавить("Страна");
		ТабРезультат.Колонки.Добавить("Представление");
		ТабРезультат.Колонки.Добавить("ИНН");
		ТабРезультат.Колонки.Добавить("СтраховойНомерПФР");
		ТабРезультат.Колонки.Добавить("ВидДокумента");
		ТабРезультат.Колонки.Добавить("Серия");
		ТабРезультат.Колонки.Добавить("Номер");
		ТабРезультат.Колонки.Добавить("ДатаВыдачи");
		ТабРезультат.Колонки.Добавить("КемВыдан");
		ТабРезультат.Колонки.Добавить("КодПодразделения");
		ТабРезультат.Колонки.Добавить("ПредставлениеДокумента");
		
		ТабРезультат.Колонки.Добавить("ТабельныйНомер");
		ТабРезультат.Колонки.Добавить("Должность");
		ТабРезультат.Колонки.Добавить("ПодразделениеОрганизации");
		ТабРезультат.Колонки.Добавить("Сотрудник");
		ТабРезультат.Колонки.Добавить("ДатаПриема");
		
	Иначе
		
		Результат = Новый Структура("Фамилия, Имя, Отчество, Пол, ДатаРождения, МестоРождения, Страна, Представление, ИНН, СтраховойНомерПФР, ТабельныйНомер, Должность, ПодразделениеОрганизации, ВидДокумента, Серия, Номер, ДатаВыдачи, КемВыдан, КодПодразделения, ПредставлениеДокумента, Сотрудник, ДатаПриема");
		
	КонецЕсли;
	
	//Для Каждого ДанныеФизЛиц Из КадровыеДанныеФизЛиц Цикл
	//	
	//	Если РезультатТаблично Тогда
	//		Результат = ТабРезультат.Добавить();
	//		Результат.ФизическоеЛицо= ДанныеФизЛиц.ФизическоеЛицо;
	//	Иначе
	//		Если КадровыеДанныеФизЛиц.Индекс(ДанныеФизЛиц) > 0 Тогда
	//			Прервать;
	//		КонецЕсли;
	//	КонецЕсли;
	//	
	//	Результат.Фамилия       = ОбщегоНазначенияБП.ЕстьNull(ДанныеФизЛиц.Фамилия, "");
	//	Результат.Имя           = ОбщегоНазначенияБП.ЕстьNull(ДанныеФизЛиц.Имя, "");
	//	Результат.Отчество      = ОбщегоНазначенияБП.ЕстьNull(ДанныеФизЛиц.Отчество, "");
	//	Результат.Пол           = ОбщегоНазначенияБП.ЕстьNull(ДанныеФизЛиц.Пол, Перечисления.ПолФизическогоЛица.ПустаяСсылка());
	//	Результат.ДатаРождения  = ОбщегоНазначенияБП.ЕстьNull(ДанныеФизЛиц.ДатаРождения, Дата(1, 1, 1));
	//	Результат.МестоРождения = ОбщегоНазначенияБП.ЕстьNull(ДанныеФизЛиц.МестоРождения, "");
	//	Результат.Страна        = ОбщегоНазначенияБП.ЕстьNull(ДанныеФизЛиц.Страна, Справочники.СтраныМира.Россия);
	//	Если ФИОКратко Тогда
	//		Результат.Представление = ОбщегоНазначенияБП.ЕстьNull(ДанныеФизЛиц.ФамилияИО, "");
	//	Иначе
	//		Результат.Представление = ОбщегоНазначенияБП.ЕстьNull(ДанныеФизЛиц.ФИОПолные, "");
	//	КонецЕсли;
	//	Результат.ВидДокумента           = ОбщегоНазначенияБП.ЕстьNull(ДанныеФизЛиц.ДокументВид, "");
	//	Результат.Серия                  = ОбщегоНазначенияБП.ЕстьNull(ДанныеФизЛиц.ДокументСерия, "");
	//	Результат.Номер                  = ОбщегоНазначенияБП.ЕстьNull(ДанныеФизЛиц.ДокументНомер, "");
	//	Результат.ДатаВыдачи             = ОбщегоНазначенияБП.ЕстьNull(ДанныеФизЛиц.ДокументДатаВыдачи, "");
	//	Результат.КемВыдан               = ОбщегоНазначенияБП.ЕстьNull(ДанныеФизЛиц.ДокументКемВыдан, "");
	//	Результат.КодПодразделения       = ОбщегоНазначенияБП.ЕстьNull(ДанныеФизЛиц.ДокументКодПодразделения, "");
	//	Результат.ПредставлениеДокумента = ОбщегоНазначенияБП.ЕстьNull(ДанныеФизЛиц.ДокументПредставление, "");
	//	Результат.ИНН                    = ОбщегоНазначенияБП.ЕстьNull(ДанныеФизЛиц.ИНН, "");
	//	Результат.СтраховойНомерПФР      = ОбщегоНазначенияБП.ЕстьNull(ДанныеФизЛиц.СтраховойНомерПФР, "");
	//	
	//	Если КадровыеДанныеСотрудников <> Неопределено Тогда
	//		СтруктураОтбора = Новый Структура("ФизическоеЛицо", ДанныеФизЛиц.ФизическоеЛицо);
	//		МассивСведений = КадровыеДанныеСотрудников.НайтиСтроки(СтруктураОтбора);
	//		Если МассивСведений.Количество() <> 0 Тогда
	//			Результат.ТабельныйНомер           = МассивСведений[0].ТабельныйНомер;
	//			Результат.Должность                = МассивСведений[0].Должность;
	//			Результат.ПодразделениеОрганизации = МассивСведений[0].Подразделение;
	//			Результат.Сотрудник                = МассивСведений[0].Сотрудник;
	//			Результат.ДатаПриема               = МассивСведений[0].ДатаПриема;
	//		КонецЕсли;
	//	КонецЕсли;
	//КонецЦикла;
	
	Если РезультатТаблично Тогда
		Возврат ТабРезультат;
	Иначе
		Возврат Результат;
	КонецЕсли;
	
КонецФункции
