/// <summary>
/// Codeunit WSC Security Managements (ID 81005).
/// </summary>
codeunit 81005 "WSC Security Managements"
{
    trigger OnRun()
    begin

    end;

    [NonDebuggable]
    internal procedure SetToken(var TokenKey: Guid; TokenValue: Text; TokenDataScope: DataScope) NewToken: Boolean
    begin
        if IsNullGuid(TokenKey) then
            NewToken := true;
        if NewToken then
            TokenKey := CreateGuid();

        if EncryptionEnabled() then
            IsolatedStorage.SetEncrypted(TokenKey, TokenValue, TokenDataScope)
        else
            IsolatedStorage.Set(TokenKey, TokenValue, TokenDataScope);
    end;

    [NonDebuggable]
    internal procedure SetTokenForceNoEncryption(var TokenKey: Guid; TokenValue: Text; TokenDataScope: DataScope) NewToken: Boolean
    begin
        if IsNullGuid(TokenKey) then
            NewToken := true;
        if NewToken then
            TokenKey := CreateGuid();

        IsolatedStorage.Set(TokenKey, TokenValue, TokenDataScope);
    end;

    /// <summary>
    /// GetToken.
    /// </summary>
    /// <param name="TokenKey">Guid.</param>
    /// <param name="TokenDataScope">DataScope.</param>
    /// <returns>Return variable TokenValue of type Text.</returns>
    [NonDebuggable]
    procedure GetToken(TokenKey: Guid; TokenDataScope: DataScope) TokenValue: Text;
    begin
        if not HasToken(TokenKey, TokenDataScope) then
            exit('');

        IsolatedStorage.Get(TokenKey, TokenDataScope, TokenValue);
    end;

    /// <summary>
    /// HasToken.
    /// </summary>
    /// <param name="TokenKey">Guid.</param>
    /// <param name="TokenDataScope">DataScope.</param>
    /// <returns>Return value of type Boolean.</returns>
    procedure HasToken(TokenKey: Guid; TokenDataScope: DataScope): Boolean
    begin
        exit(not IsNullGuid(TokenKey) and IsolatedStorage.Contains(TokenKey, TokenDataScope));
    end;

    /// <summary>
    /// DeleteToken.
    /// </summary>
    /// <param name="TokenKey">Guid.</param>
    /// <param name="TokenDataScope">DataScope.</param>
    /// <returns>Return value of type Boolean.</returns>
    procedure DeleteToken(TokenKey: Guid; TokenDataScope: DataScope): Boolean
    begin
        if not HasToken(TokenKey, TokenDataScope) then
            exit;

        if IsolatedStorage.Delete(TokenKey, TokenDataScope) then
            exit(true);
    end;
}