// Возвращает логин и пароль пользователя Интернет-поддержки,
// сохраненные в информационной базе.
//
// Возвращаемое значение:
//	Структура - структура, содержащая логин и пароль пользователя
//		Интернет-поддержки:
//		* Логин - Строка - логин пользователя Интернет-поддержки;
//		* Пароль - Строка - пароль пользователя Интернет-поддержки, отсутствует,
//			если пользователь не установил флаг "Запомнить меня".
//	Неопределено - при отсутствии сохраненных данных авторизации.
//
Функция ДанныеАутентификацииПользователяИнтернетПоддержки() Экспорт
	
	ЗапросПараметров = Новый Запрос(
	"ВЫБРАТЬ
	|	ПараметрыИнтернетПоддержкиПользователей.Имя КАК ИмяПараметра,
	|	ПараметрыИнтернетПоддержкиПользователей.Значение КАК ЗначениеПараметра
	|ИЗ
	|	РегистрСведений.ПараметрыИнтернетПоддержкиПользователей КАК ПараметрыИнтернетПоддержкиПользователей
	|ГДЕ
	|	ПараметрыИнтернетПоддержкиПользователей.Имя В (""login"", ""password"")
	|	И ПараметрыИнтернетПоддержкиПользователей.Пользователь = &ПустойИдентификатор");
	
	ЗапросПараметров.УстановитьПараметр("ПустойИдентификатор",
		Новый УникальныйИдентификатор("00000000-0000-0000-0000-000000000000"));
	
	
	ЛогинПользователя  = Неопределено;
	ПарольПользователя = Неопределено;
	
	УстановитьПривилегированныйРежим(Истина);
	ВыборкаПараметров = ЗапросПараметров.Выполнить().Выбрать();
	Пока ВыборкаПараметров.Следующий() Цикл
		
		// В запросе регистр символов не учитывается
		ИмяПараметраНРег = НРег(ВыборкаПараметров.ИмяПараметра);
		Если ИмяПараметраНРег = "login" Тогда
			ЛогинПользователя = ВыборкаПараметров.ЗначениеПараметра;
			
		ИначеЕсли ИмяПараметраНРег = "password" Тогда
			ПарольПользователя = ВыборкаПараметров.ЗначениеПараметра;
			
		КонецЕсли;
		
	КонецЦикла;
	
	Если ЛогинПользователя <> Неопределено И ПарольПользователя <> Неопределено Тогда
		Возврат Новый Структура("Логин, Пароль", ЛогинПользователя, ПарольПользователя);
	Иначе
		Возврат Неопределено;
	КонецЕсли;
	
КонецФункции
