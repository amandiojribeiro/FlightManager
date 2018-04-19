namespace Infrastructure.Crosscuting
{
    public static class TypeAdapterFactory
    {
        #region Members

        private static ITypeAdapterFactory currentTypeAdapterFactory;
        private static ITypeAdapter currentAdapter;

        #endregion Members

        #region Public Static Methods

        /// <summary>
        /// Set the current type adapter factory
        /// </summary>
        /// <param name="adapterFactory">The adapter factory to set</param>
        public static void SetCurrent(ITypeAdapterFactory adapterFactory)
        {
            currentTypeAdapterFactory = adapterFactory;
        }

        /// <summary>
        /// Create a new type adapter from currect factory
        /// </summary>
        /// <returns>Created type adapter</returns>
        public static ITypeAdapter CreateAdapter()
        {
            if (currentAdapter == null)
            {
                currentAdapter = currentTypeAdapterFactory.Create();
            }

            return currentAdapter;
        }

        #endregion Public Static Methods
    }
}
