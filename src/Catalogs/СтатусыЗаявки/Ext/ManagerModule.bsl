﻿Функция ПолучитьСтатусОтмена() Экспорт
	
	Возврат Справочники.СтатусыЗаявки.НайтиПоКоду("000");
	
КонецФункции

Функция ПолучитьСтатусНачало() Экспорт
	
	//Запрос = Новый Запрос(
	//"ВЫБРАТЬ
	//|	СтатусыЗаявки.Ссылка
	//|ИЗ
	//|	Справочник.СтатусыЗаявки КАК СтатусыЗаявки
	//|ГДЕ
	//|	НЕ СтатусыЗаявки.Ссылка В
	//|				(ВЫБРАТЬ
	//|					СтатусыЗаявки.Следующий.Ссылка
	//|				ИЗ
	//|					Справочник.СтатусыЗаявки КАК СтатусыЗаявки
	//|				ГДЕ
	//|					СтатусыЗаявки.Следующий <> ЗНАЧЕНИЕ(Справочник.СтатусыЗаявки.ПустаяСсылка))
	//|	И ""000"" < СтатусыЗаявки.Код
	//|	И СтатусыЗаявки.Код < ""900"""
	//);
	//
	//Результат = Запрос.Выполнить();
	//
	//Если Результат.Пустой() Тогда
	//	Возврат Справочники.СтатусыЗаявки.ПустаяСсылка();
	//КонецЕсли;
	//
	//Выборка = Результат.Выбрать();
	//Выборка.Следующий();
	//
	//Возврат Выборка.Ссылка;
	
	Возврат Справочники.СтатусыЗаявки.НайтиПоКоду("001");
	
КонецФункции

Функция ПолучитьСтатусФиниша() Экспорт
	
	Запрос = Новый Запрос(
	"ВЫБРАТЬ
	|	СтатусыЗаявки.Следующий.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.СтатусыЗаявки КАК СтатусыЗаявки
	|ГДЕ
	|	СтатусыЗаявки.Следующий.Следующий = ЗНАЧЕНИЕ(Справочник.СтатусыЗаявки.ПустаяСсылка)
	|	И ""000"" < СтатусыЗаявки.Следующий.Код
	|	И СтатусыЗаявки.Следующий.Код < ""900"""
	);
	
	Результат = Запрос.Выполнить();
	
	Если Результат.Пустой() Тогда
		Возврат Справочники.СтатусыЗаявки.ПустаяСсылка();
	КонецЕсли;
	
	Выборка = Результат.Выбрать();
	Выборка.Следующий();
	
	Возврат Выборка.Ссылка;
	
КонецФункции

Функция ПолучитьСтатусЗакрыт(ПолностьюЗакрыт=Истина) Экспорт
	
	Возврат Справочники.СтатусыЗаявки.НайтиПоКоду(?(ПолностьюЗакрыт, "999", "900"));
	
КонецФункции

Функция ПроверитьДоступСтатуса(Статус, Пользователь=Неопределено, Ответственный=Неопределено) Экспорт
	
	Если Пользователь = Неопределено Тогда
		Пользователь = Пользователи.ТекущийПользователь();
	КонецЕсли;
	
	Если Статус = ПолучитьСтатусНачало() И Ответственный <> Неопределено Тогда	//-= при формировании документа
		Возврат Пользователь = Ответственный;									//-= может редактировать ТОЛЬКО ответственный
	КонецЕсли;
	
	Данные = глОбщий.ПолучитьСотрудникаПоФизЛицу(Пользователь.ФизЛицо, ТекущаяДата());
	
	Должность = Данные.Должность;
	Подразделение = Данные.ПодразделениеОрганизации;		
	
	ЕстьДоступ = Ложь;
	
	Если Статус.КадровыеДанные.Количество() = 0 И Статус.Пользователи.Количество()=0 Тогда
		ЕстьДоступ = Истина;
	КонецЕсли;
	
	Если Не ЕстьДоступ И Статус.Пользователи.Количество()>0 Или Статус.Пользователи.Найти(Пользователь, "Пользователь") <> Неопределено Тогда
		ЕстьДоступ = Истина;
	КонецЕсли;
	
	Если Не ЕстьДоступ Тогда
		ПараметрыОтбора = Новый Структура("Должность, Подразделение", Должность, Подразделение);
		ЕстьДоступ = (Статус.КадровыеДанные.НайтиСтроки(ПараметрыОтбора).Количество()>0);
	КонецЕсли;
	
	Если Не ЕстьДоступ Тогда
		ПараметрыОтбора = Новый Структура("Должность, Подразделение", Справочники.ДолжностиОрганизаций.ПустаяСсылка(), Подразделение);
		ЕстьДоступ = (Статус.КадровыеДанные.НайтиСтроки(ПараметрыОтбора).Количество()>0);
	КонецЕсли;
		
	Если Не ЕстьДоступ Тогда
		ПараметрыОтбора = Новый Структура("Должность, Подразделение", Должность, Справочники.ПодразделенияОрганизаций.ПустаяСсылка());
		ЕстьДоступ = (Статус.КадровыеДанные.НайтиСтроки(ПараметрыОтбора).Количество()>0);
	КонецЕсли;
	
	Возврат ЕстьДоступ;
	
КонецФункции